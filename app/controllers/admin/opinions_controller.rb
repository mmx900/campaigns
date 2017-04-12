class Admin::OpinionsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @opinions = Opinion.all.recent
  end

  def create
    if @opinion.save
      redirect_to admin_opinions_path
    else
      render 'new'
    end
  end

  def update
    if @opinion.update(opinion_params)
      redirect_to admin_opinions_path
    else
      render 'edit'
    end
  end

  def destroy
    @opinion.destroy
    redirect_to admin_opinions_path
  end

  def new_or_edit
    issue = Issue.find params[:issue_id]
    speaker = Speaker.find params[:speaker_id]
    @opinion = speaker.opinions.of_issue(issue).first || issue.opinions.build(speaker: speaker)
    if @opinion.new_record?
      render 'new'
    else
      render 'edit'
    end
  end

  private

  def opinion_params
    params.require(:opinion).permit(:issue_id, :speaker_id, :quote, :body, :stance)
  end
end
