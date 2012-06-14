# == Schema Information
#
# Table name: institutes
#
#  id               :integer          not null, primary key
#  dtu_institute_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Institute < ActiveRecord::Base
  has_many :courses
  translates :title
  
  def display
    if dtu_institute_id < 10
      "0#{dtu_institute_id} #{title}"
    else 
      "#{dtu_institute_id} #{title}"
    end
  end
end
