# == Schema Information
#
# Table name: institutes
#
#  id               :integer         not null, primary key
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  dtu_institute_id :integer
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
