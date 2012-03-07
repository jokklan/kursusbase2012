class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_locale
  
  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end
  
  def set_locale
    I18n.locale = params[:locale] || ((lang = request.env['HTTP_ACCEPT_LANGUAGE']) && lang[/^[a-z]{2}/])
  end
end
