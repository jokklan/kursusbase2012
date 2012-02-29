# == Schema Information
#
# Table name: evaluations
#
#  id              :integer         not null, primary key
#  course_id       :integer
#  exam_schedule   :string(255)
#  exam_form       :string(255)
#  exam_duration   :time
#  exam_aid        :string(255)
#  evaluation_form :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class Evaluation < ActiveRecord::Base
  belongs_to :course
end
