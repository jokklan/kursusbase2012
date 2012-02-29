# == Schema Information
#
# Table name: keywords
#
#  id         :integer         not null, primary key
#  keyword    :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Keywords < ActiveRecord::Base
  has_and_belongs_to_many :courses
end
