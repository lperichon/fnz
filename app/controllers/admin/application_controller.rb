require 'typhoeus_fix/array_decoder'

class Admin::ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :require_admin_role!
  protect_from_forgery
  layout "application"  
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  private

  def require_admin_role!
    unless current_user.has_role? :admin
      redirect_to root_path, :alert => "Must be admin"
    end
  end
end
