# == Schema Information
#
# Table name: keywords
#
#  id         :integer         not null, primary key
#  keyword    :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Keyword < ActiveRecord::Base
  has_and_belongs_to_many :courses
  translates :keyword
end
