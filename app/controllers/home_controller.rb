class HomeController < UserApplicationController
  before_filter :redirect_to_school

  def index
  end

  private

  def redirect_to_school
  	redirect_to overview_business_memberships_path(:business_id => current_user.padma.current_account_name)
  end
end
