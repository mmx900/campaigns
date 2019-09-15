module CampaignStepsHelper
  STEPS = %w(set_goal add_detail)
  MULTI_STEPS = {
    "petition"     => %w(set_agenda set_issue set_goal add_detail),
    "order"       => "",
    "picket"      => %w(set_picket),
    "basic"       => %w(set_agenda set_issue set_goal add_detail),
    "photo"      => %w(set_agenda set_issue set_goal add_detail),
    "map"        => %w(set_agenda set_issue set_goal add_detail),
    "sympathy" => %w(add_detail)
  }

  def campaign_step_model
    campaign_class = "Campaign::#{step.camelcase}".constantize rescue Campaign
    @campaign ||= campaign_class.find(params[:campaign_id])
  end

  def step
    wizard, klass = params[:id].split("=")
    if wizard.present?
      MULTI_STEPS[wizard].find { |s| s == klass.to_s.downcase }
    else
      STEPS.find { |s| s == params[:id].to_s.downcase }
    end
  end

  def include_wizard?  wizard
    MULTI_STEPS.keys.include? wizard
  end

  def first_step wizard=nil
    if wizard.present?
      MULTI_STEPS[wizard][0]
    else
      STEPS[0]
    end
  end

  def previous_step
    wizard, klass = params[:id].split("=")

    if wizard.present?
      current_step_index = MULTI_STEPS[wizard].index(step)
      previous_step_index = current_step_index - 1
      previous_step_index < 0 ? nil : MULTI_STEPS[wizard][previous_step_index]
    else
      current_step_index = STEPS.index(step)
      previous_step_index = current_step_index - 1
      previous_step_index < 0 ? nil : STEPS[previous_step_index]
    end
  end

  def next_step
    wizard, klass = params[:id].split("=")
    if wizard.present?
      current_step_index = MULTI_STEPS[wizard].index(step)
      MULTI_STEPS[wizard][current_step_index + 1]
    else
      current_step_index = STEPS.index(step)
      STEPS[current_step_index + 1]
    end
  end
end
