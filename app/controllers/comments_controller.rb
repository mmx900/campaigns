class CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:create, :index, :show]
  load_and_authorize_resource

  def index
    if params[:commentable_type].nil?
      redirect_to root_url
    else
      @commentable_model = params[:commentable_type].classify.safe_constantize
      @commentable = @commentable_model.find(params[:commentable_id])
      @comments = @commentable.comments.page(params[:page])
      @comments = @comments.with_target_speaker(Speaker.find_by(id: params[:speaker_id])) if params[:speaker_id].present?
    end
  end

  def create
    if params[:i_am] != 'your_father'
      if !verify_recaptcha(model: @comment) and !user_signed_in?
        redirect_back_for_robot and return
      end
    end

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

    if @comment.mailing.ready? and @comment.commentable.respond_to?(:speakers)
      if @comment.target_speaker_id.blank?
        @comment.commentable.speakers.each do |speaker|
          @comment.target_speakers << speaker
        end
      else
        @comment.target_speakers << Speaker.find_by(id: @comment.target_speaker_id)
      end
    end

    if @comment.save
      flash[:notice] = I18n.t('messages.commented')

      if @comment.mailing.ready?
        if @comment.target_speakers.empty? { |s| s.email.present? }
          @comment.update_attributes(mailing: :fail)
        else
          if @comment.commentable.respond_to? :statements
            @comment.target_speakers.each do |speaker|
              statement = @comment.commentable.statements.find_or_create_by(speaker: speaker)
              statement_key = statement.statement_keys.build(key: SecureRandom.hex(50))
              statement_key.save!
              CommentMailer.target_speaker(@comment.id, speaker.id, statement_key.id).deliver_later
            end
          end
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
      :target_speaker_id, :mailing,
      :toxic
    )
  end
end
