class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_locale
  
  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end
  
  def set_locale
    I18n.locale = params[:locale] || cookies[:locale] || I18n.default_locale
    cookies[:locale] = I18n.locale
  end

	def call_rake(task, options = {})
	  options[:rails_env] ||= Rails.env
	  args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
	  system "/usr/bin/rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
	end
	
	def login
    @student = Student.find_or_initialize_by_student_number(params[:student][:student_number])

		# Dummy field of study
		field_of_study = FieldOfStudy.find_by_title('Softwareteknologi')
    @student.field_of_study = field_of_study

    @student.password = params[:student][:password]
    if @student.authenticate(params[:student][:password]) && (
      if @student.new_record? || @student.user_id.nil?
        @student.update_info
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
    puts "HEJ"
    @current_student ||= Student.find(session[:student_id]) if session[:student_id] && Student.exists?(session[:student_id])
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
