module RedirectBackHelper

  def store_location
    session[:return_to] = request.referer
  end

  def redirect_back_or_default_to(default=nil,opts=nil)

    # always remove return_to from session. even if we'll use params[:return_to]
    session_return_to = session.delete(:return_to)

    destination = if params[:return_to]
      params[:return_to]
    elsif session_return_to
      session_return_to
    elsif default
      default
    else
      :back
    end
    redirect_to destination, opts
  end
end
