# == Schema Information
#
# Table name: users
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  direction_id :integer
#  start_year   :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class User < ActiveRecord::Base
  belongs_to :field_of_study
  has_many :course_users
  has_many :courses, :through => :course_users
  
  attr_accessor :password
  
  attr_accessible :student_number, :password
  
  validates :student_number, :presence => true, :uniqueness => true
  
  def authenticate(password)
    require "net/http"
    require "uri"

    uri = URI.parse("https://auth.dtu.dk/dtu/mobilapp.jsp")

    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"username" => self.student_number, "password" => password})
    response = http.request(request)
    cn_access_key = response.body.split('"')[1]
  end
    
end
