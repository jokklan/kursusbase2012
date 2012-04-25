class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_locale
  
  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end
  
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  
  private

  def current_student
    @current_student ||= Student.find(session[:student_id]) if session[:student_id]
  end
  helper_method :current_student

  def authorize
    redirect_to login_url, alert: "Not authorized" if current_student.nil?
  end
  
  def alt_language
    if I18n.locale == :da
      :en
    elsif I18n.locale == :en
      :da
    end
  end
  helper_method :alt_language
end
