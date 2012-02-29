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
end
