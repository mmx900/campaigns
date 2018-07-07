class CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:create, :index, :show]
  load_and_authorize_resource
  invisible_captcha only: [:create]

  def index
    if params[:commentable_type].nil?
      redirect_to root_url
    else
      @commentable_model = params[:commentable_type].classify.safe_constantize
      @commentable = @commentable_model.find(params[:commentable_id])
      @comments = @commentable.comments.page(params[:page])
      @comments = @comments.with_target_agent(Agent.find_by(id: params[:agent_id])) if params[:agent_id].present?
    end
  end

  def create
    @comment.user = current_user if user_signed_in?
    if user_signed_in? and @comment.commentable.respond_to? :voted_by? and @comment.commentable.voted_by? current_user
      @comment.choice = @comment.commentable.fetch_vote_of(current_user).choice
    end

    @comment.mailing ||= :disable
    if @comment.mailing.ready? and @comment.user_id.blank? and @comment.commenter_email.blank?
      flash[:error] = I18n.t('messages.need_to_email')
      redirect_back(fallback_location: root_path, i_am: params[:i_am])
      return
    end

    if @comment.commentable.respond_to?(:agents)
      if @comment.target_agent_id.blank?
        @comment.commentable.not_agree_agents.each do |agent|
          @comment.target_agents << agent
        end
      else
        @comment.target_agents << Agent.find_by(id: @comment.target_agent_id)
      end
    end

    if @comment.save
      flash[:notice] = I18n.t('messages.commented')

      if @comment.commentable.try(:statementable?)
        @comment.target_agents.each do |agent|
          statement = @comment.commentable.statements.find_or_create_by(agent: agent)
          statement_key = statement.statement_keys.build(key: SecureRandom.hex(50))
          statement_key.save!
          if @comment.mailing.ready? and agent.email.present?
            CommentMailer.target_agent(@comment.id, agent.id, statement_key.id).deliver_later
          end
        end
      end

      if @comment.mailing.ready?
        if @comment.target_agents.empty? { |agent| agent.email.present? }
          @comment.update_attributes(mailing: :fail)
        end
      end
    else
      errors_to_flash(@comment)
    end

    if params[:back_commentable].present?
      redirect_to @comment.commentable
    else
      redirect_back(fallback_location: root_path, i_am: params[:i_am])
    end
  end

  def update
    @comment.update(comment_params)
  end

  def destroy
    @comment.destroy
    redirect_to :back
  end

  private

  def comment_params
    params.require(:comment).permit(
      :body, :commentable_id, :commentable_type,
      :commenter_name, :commenter_email,
      :full_street_address,
      :tag_list, :image,
      :target_agent_id, :mailing,
      :toxic
    )
  end
end
