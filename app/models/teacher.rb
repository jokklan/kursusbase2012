# == Schema Information
#
# Table name: teachers
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  location   :string(255)
#  phone      :string(255)
#  email      :string(255)
#  website    :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Teacher < ActiveRecord::Base
  has_and_belongs_to_many :courses
end
