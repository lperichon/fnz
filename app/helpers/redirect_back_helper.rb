module RedirectBackHelper

  def store_location
    debug "storing location #{request.referer}"
    session[:return_to] = request.referer
  end

  def redirect_back_or_default_to(default=nil,opts=nil)
    debug "in redirect_back_or_default"
    debug "session return_to is #{session[:return_to]}"
    debug "default is #{default}"

    destination = if session[:return_to]
      session.delete(:return_to)
    elsif default
      default
    else
      :back
    end

    debug "redirecting to #{destination}"
    redirect_to destination, opts
  end

  def debug(msg)
    Rails.logger.warn "loggin-shit: ===============================> #{msg}"
  end
end
