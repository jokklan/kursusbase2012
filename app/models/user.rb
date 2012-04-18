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
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable, :omniauthable, 
  # :registerable, :recoverable, :database_authenticatable
  devise :token_authenticatable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me
  belongs_to :field_of_study
  has_many :course_users
  has_many :courses, :through => :course_users
end
