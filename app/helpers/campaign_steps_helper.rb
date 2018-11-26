module CampaignStepsHelper
  STEPS = %w(set_goal add_detail)

  def campaign_step_model
    campaign_class = "Campaign::#{step.camelcase}".constantize rescue Campaign
    @campaign ||= campaign_class.find(params[:campaign_id])
  end

  def step
    STEPS.find { |s| s == params[:id].to_s.downcase }
  end

  def previous_step
    current_step_index = STEPS.index(step)
    previous_step_index = current_step_index - 1
    previous_step_index < 0 ? nil : STEPS[previous_step_index]
  end

  def next_step
    current_step_index = STEPS.index(step)
    STEPS[current_step_index + 1]
  end
end
