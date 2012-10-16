class UserApplicationController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_current_user
  before_filter :set_time_zone

  def set_current_user
    User.current_user = current_user if current_user
  end

  def set_time_zone
    Time.zone = current_user.time_zone if current_user
  end
end