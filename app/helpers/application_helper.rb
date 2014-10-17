module ApplicationHelper
  include TzMagic::ApplicationHelper

  def redirect_back_or_default(default=nil,opts=nil)
    if session[:return_to]
      redirect_to session.delete(:return_to), opts
    elsif default
      redirect_to default, opts
    else
      redirect_to :back, opts
    end
  end

  def memberships_link_active?
    controller.controller_name == "memberships" && controller.action_name != 'maturity_report'
  end

  def maturity_report_active?
    controller.controller_name == "memberships" && controller.action_name == 'maturity_report'
  end
end
