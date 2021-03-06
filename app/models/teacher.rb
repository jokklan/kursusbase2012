# == Schema Information
#
# Table name: teachers
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  location       :string(255)
#  phone          :string(255)
#  email          :string(255)
#  dtu_teacher_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Teacher < ActiveRecord::Base
  has_and_belongs_to_many :courses
  
  
  def link
    "http://www.dtu.dk/Service/Telefonbog.aspx?id=#{self.dtu_teacher_id}&type=person&lg=showcommon"
  end
  
  def image(width)
    "https://www.dtubasen.dtu.dk/showimage.aspx?id=#{self.dtu_teacher_id}&x=#{width}"
  end
end
