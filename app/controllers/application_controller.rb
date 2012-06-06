class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_locale
  
  # Ransack, Meta Search
  # before_filter :course_search
  # # 
  # def course_search
  #   @q = Course.search(params[:q])
  # end
  
  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end
  
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

	def call_rake(task, options = {})
	  options[:rails_env] ||= Rails.env
	  args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
	  system "/usr/bin/rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
	end
	
	def login
    @student = Student.find_or_initialize_by_student_number(params[:student][:student_number])
    
    @student.password = params[:student][:password]
    if (
      if @student.new_record? || @student.firstname.nil?
        @student.update_attributes(@student.get_info.select{|k,v| [:firstname, :lastname, :email].include? k}, password: params[:student][:password])
      else
        @student.save
      end )
      
      session[:student_id] = @student.id
      @student.update_courses
      
      respond_to do |format|
        format.html { redirect_to root_url, notice: "Logged in!" }
        format.js   { redirect_to root_url, notice: "Logged in!" }
      end
    else
      flash[:alert] = @student.errors[:base]
      respond_to do |format|
        format.html { redirect_to flash[:return_url] || root_url }
        format.js   { render :nothing => true, :json => { :error => @student.errors[:base].first }, :status => :unprocessable_entity }
      end
    end
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
