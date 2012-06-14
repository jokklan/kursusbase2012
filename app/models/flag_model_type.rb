# == Schema Information
#
# Table name: flag_model_types
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FlagModelType < ActiveRecord::Base
	has_many :spec_course_types
end
