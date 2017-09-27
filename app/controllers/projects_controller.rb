class ProjectsController < ApplicationController
  include OrganizationHelper

  load_and_authorize_resource find_by: :slug
  before_action :reset_meta_tags, only: [:show, :events]
  before_action :fetch_current_organization, only: [:show, :edit]

  def index
    @projects = Project.order('id DESC')
    @current_organization = fetch_organization_of_request(request)
    @projects = @projects.where(organization: @current_organization) if @current_organization.present?
  end

  def show

    @project.increment!(:views_count)
  end

  def events
    @project.increment!(:views_count)
  end

  def new
  end
  #create 도 프로젝트 조직 슬러그 들어가야 함
  def create
    @project = Project.new(project_params)
    @project.user = current_user
    if @project.save
      redirect_to @project
    else
      errors_to_flash(@project)
      render 'new'
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project
    else
      errors_to_flash(@project)
      render 'edit'
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path
  end

  private

  def fetch_current_organization
    @current_organization = @project.organization
  end

  def project_params
    params.require(:project).permit(
      :title, :subtitle, :body,
      :image, :remove_image,
      :social_image, :remove_social_image,
      :slug, :organization_id,
      :story_enabled, :discussion_enabled, :poll_enabled, :petition_enabled, :wiki_enabled,
      :story_title, :discussion_title, :poll_title, :petition_title, :wiki_title,
      :story_sequence, :discussion_sequence, :poll_sequence, :petition_sequence, :wiki_sequence, :event_sequence
    )
  end

  def reset_meta_tags
    prepare_meta_tags({
      title: @project.title,
      description: @project.body.html_safe,
      image: view_context.image_url(@project.fallback_social_image_url),
      url: request.original_url}
    )
  end
end
