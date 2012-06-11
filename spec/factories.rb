FactoryGirl.define do

  factory :course do
    course_number 12345
    title "test"
  end
  
  factory :schedule do
    block "F2B"
  end
  
end