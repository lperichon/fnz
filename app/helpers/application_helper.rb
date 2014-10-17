module ApplicationHelper
  include TzMagic::ApplicationHelper

  def memberships_link_active?
    controller.controller_name == "memberships" && controller.action_name != 'maturity_report'
  end

  def maturity_report_active?
    controller.controller_name == "memberships" && controller.action_name == 'maturity_report'
  end
end
