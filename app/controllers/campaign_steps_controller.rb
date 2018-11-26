class CampaignStepsController < ApplicationController
  include CampaignStepsHelper
  # load_and_authorize_resource
  before_action :load_campaign

  def edit
    if campaign_step_model.editable?
      if step.present?
        render step
      else
        render status: :not_found
      end
    else
      redirect_to :back, alert: "editable error"
    end
  end

  def update
    logger.info "update"
    if campaign_step_model.update_attributes(campaign_params || {})
      logger.info "next_step: #{next_step}"
      if next_step && params[:commit].downcase.include?('next')
        redirect_to edit_campaign_campaign_step_path(campaign_step_model, next_step)
      else
        logger.info "publish"
        @campaign.update_attributes(draft: false)
        redirect_to published_campaign_path(@campaign)
        # redirect_to campaing_path(@campaign)
      end
    else
      render step, error: "Please complete all required fields"
    end
  end

private

  def load_campaign
    @campaign = campaign_step_model
    authorize! :read, @campaign
  end

  def campaign_params
    params.require(:campaign).permit(:title, :body, :project_id, :signs_goal_count, :cover_image, :thanks_mention,
      :comment_enabled, :sign_title, :social_image, :confirm_privacy,
      :use_signer_email, :use_signer_address, :use_signer_real_name, :use_signer_phone,
      :signer_email_title, :signer_address_title, :signer_real_name_title, :signer_phone_title,
      :agent_section_title, :agent_section_response_title, :sign_hidden, :area_id, :issue_id,
      :special_slug, :sign_form_intro, (:template if params[:action] == 'create'), :slug, :title_to_agent, :message_to_agent,
      :closed_at)
  end
end
