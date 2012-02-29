# == Schema Information
#
# Table name: institutes
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Institute < ActiveRecord::Base
  has_many :courses
  
  def display
    if dtu_institute_id < 10
      "0#{dtu_institute_id} #{title}"
    else 
      "dtu_institude_id #{title}"
    end
  end
end
