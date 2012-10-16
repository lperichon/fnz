class RegistrationsController < Devise::RegistrationsController
  include TzMagic::BeforeFilter

  skip_before_filter :ensure_timezone, :only => :edit
end