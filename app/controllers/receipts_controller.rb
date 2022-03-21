class ReceiptsController < ApplicationController

  layout "receipts"

  before_action :set_locale

  def show
    @receipt = Receipt.w_secret(params[:s]).find(params[:id])
  end

  private

  def set_locale
    I18n.locale = if current_user
      current_user.locale
    elsif params[:locale]
      params[:locale]
    else
      extract_browser_locale(request.env['HTTP_ACCEPT_LANGUAGE'])
    end
  end

  def extract_browser_locale(http_accept_language)
    http_accept_language.to_s.scan(/[a-z]{2}(?:-[A-Z]{2})?/).detect do |candidate|
      I18n.available_locales.include?(candidate.to_sym)
    end
  end

end
