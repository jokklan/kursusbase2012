# == Schema Information
#
# Table name: field_of_studies
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class FieldOfStudy < ActiveRecord::Base
  has_many :users
end
