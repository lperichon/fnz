class UserApplicationController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_current_user

  def set_current_user
    User.current_user = current_user if current_user
  end
end