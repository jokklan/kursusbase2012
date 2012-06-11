# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120608084734) do

  create_table "course_recommendations", :force => true do |t|
    t.integer  "student_id"
    t.integer  "course_id"
    t.integer  "priority_value"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "course_recommendations", ["course_id"], :name => "index_course_recommendations_on_course_id"
  add_index "course_recommendations", ["student_id"], :name => "index_course_recommendations_on_student_id"

  create_table "course_relations", :force => true do |t|
    t.integer  "course_id"
    t.integer  "related_course_id"
    t.integer  "group_no"
    t.string   "related_course_type"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "course_relations", ["course_id"], :name => "index_course_relations_on_course_id"
  add_index "course_relations", ["related_course_id"], :name => "index_course_relations_on_related_course_id"

  create_table "course_specializations", :force => true do |t|
    t.integer  "course_id"
    t.integer  "spec_course_type_id"
    t.boolean  "optional",             :default => false
    t.string   "recommended_semester"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "course_specializations", ["spec_course_type_id"], :name => "index_course_specializations_on_spec_course_type_id"

  create_table "course_student_data", :force => true do |t|
    t.integer "course_id"
    t.integer "student_data_id"
    t.string  "semester"
  end

  add_index "course_student_data", ["course_id"], :name => "index_course_student_data_on_course_id"
  add_index "course_student_data", ["student_data_id"], :name => "index_course_student_data_on_student_data_id"

  create_table "course_students", :force => true do |t|
    t.integer "student_id"
    t.integer "course_id"
    t.integer "semester"
    t.boolean "passed"
  end

  add_index "course_students", ["course_id"], :name => "index_course_users_on_course_id"
  add_index "course_students", ["student_id"], :name => "index_course_users_on_user_id"

  create_table "course_translations", :force => true do |t|
    t.integer  "course_id"
    t.string   "locale"
    t.string   "title"
    t.text     "teaching_form"
    t.string   "duration"
    t.string   "participant_limit"
    t.string   "registration"
    t.text     "course_objectives"
    t.text     "schedule_note"
    t.text     "exam_schedule"
    t.text     "learn_objectives"
    t.text     "content"
    t.text     "litteratur"
    t.text     "remarks"
    t.text     "top_comment"
    t.string   "former_course"
    t.text     "exam_form"
    t.string   "exam_aid"
    t.string   "evaluation_form"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "course_translations", ["course_id"], :name => "index_course_translations_on_course_id"
  add_index "course_translations", ["locale"], :name => "index_course_translations_on_locale"

  create_table "course_type_type_translations", :force => true do |t|
    t.integer  "course_type_type_id"
    t.string   "locale"
    t.string   "title"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "course_type_type_translations", ["course_type_type_id"], :name => "index_c2f51a55e76f32cf6609f5f6ae66b885f3f526e9"
  add_index "course_type_type_translations", ["locale"], :name => "index_course_type_type_translations_on_locale"

  create_table "course_type_types", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "courses", :force => true do |t|
    t.integer  "course_number"
    t.string   "language"
    t.float    "ects_points"
    t.boolean  "open_education"
    t.string   "schedule"
    t.integer  "institute_id"
    t.string   "homepage"
    t.string   "exam_duration"
    t.string   "point_block"
    t.string   "qualified_prereq"
    t.string   "optional_prereq"
    t.string   "mandatory_prereq"
    t.boolean  "active"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "semester_span",    :default => 1
  end

  add_index "courses", ["course_number"], :name => "index_courses_on_course_number"

  create_table "courses_keywords", :force => true do |t|
    t.integer "keyword_id"
    t.integer "course_id"
  end

  create_table "courses_main_course_types", :force => true do |t|
    t.integer "course_id"
    t.integer "main_course_type_id"
  end

  add_index "courses_main_course_types", ["course_id"], :name => "index_courses_main_course_types_on_course_id"
  add_index "courses_main_course_types", ["main_course_type_id"], :name => "index_courses_main_course_types_on_main_course_type_id"

  create_table "courses_schedules", :force => true do |t|
    t.integer "schedule_id"
    t.integer "course_id"
  end

  add_index "courses_schedules", ["course_id"], :name => "index_courses_schedules_on_course_id"
  add_index "courses_schedules", ["schedule_id"], :name => "index_courses_schedules_on_schedule_id"

  create_table "courses_teachers", :force => true do |t|
    t.integer "teacher_id"
    t.integer "course_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "field_of_studies", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "field_of_study_translations", :force => true do |t|
    t.integer  "field_of_study_id"
    t.string   "locale"
    t.string   "title"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "field_of_study_translations", ["field_of_study_id"], :name => "index_27bda481b67c1e3f5247a78db908a9591977c7ff"
  add_index "field_of_study_translations", ["locale"], :name => "index_field_of_study_translations_on_locale"
  add_index "field_of_study_translations", ["title"], :name => "index_field_of_study_translations_on_title"

  create_table "flag_model_types", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "institute_translations", :force => true do |t|
    t.integer  "institute_id"
    t.string   "locale"
    t.string   "title"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "institute_translations", ["institute_id"], :name => "index_institute_translations_on_institute_id"
  add_index "institute_translations", ["locale"], :name => "index_institute_translations_on_locale"

  create_table "institutes", :force => true do |t|
    t.integer  "dtu_institute_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "keyword_translations", :force => true do |t|
    t.integer  "keyword_id"
    t.string   "locale"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "keyword_translations", ["keyword_id"], :name => "index_keyword_translations_on_keyword_id"
  add_index "keyword_translations", ["locale"], :name => "index_keyword_translations_on_locale"
  add_index "keyword_translations", ["title"], :name => "index_keyword_translations_on_title"

  create_table "keywords", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "main_course_type_translations", :force => true do |t|
    t.integer  "main_course_type_id"
    t.string   "locale"
    t.string   "title"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "main_course_type_translations", ["locale"], :name => "index_main_course_type_translations_on_locale"
  add_index "main_course_type_translations", ["main_course_type_id"], :name => "index_bf6f8e364d02619d4627cde7ecaf7ac500a81b8a"

  create_table "main_course_types", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pg_search_documents", :force => true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "schedules", :force => true do |t|
    t.string   "block"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "spec_course_types", :force => true do |t|
    t.integer  "course_type_type_id"
    t.integer  "field_of_study_id"
    t.integer  "flag_model_type_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "spec_course_types", ["course_type_type_id"], :name => "index_spec_course_types_on_course_type_type_id"
  add_index "spec_course_types", ["field_of_study_id"], :name => "index_spec_course_types_on_field_of_study_id"
  add_index "spec_course_types", ["flag_model_type_id"], :name => "index_spec_course_types_on_flag_model_type_id"

  create_table "student_data", :force => true do |t|
    t.string   "student_id"
    t.integer  "field_of_study_id"
    t.date     "start_date"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "student_data", ["field_of_study_id"], :name => "index_student_data_on_field_of_study_id"

  create_table "students", :force => true do |t|
    t.string   "student_number"
    t.integer  "direction_id"
    t.integer  "start_year"
    t.string   "cn_access_key"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.integer  "field_of_study_id"
    t.string   "image"
    t.integer  "user_id"
  end

  add_index "students", ["student_number"], :name => "index_users_on_student_number"

  create_table "studyplan_items", :force => true do |t|
    t.integer "studyplan_id"
    t.integer "course_id"
    t.integer "student_id"
    t.integer "semester"
  end

  add_index "studyplan_items", ["course_id"], :name => "index_studyplan_items_on_course_id"
  add_index "studyplan_items", ["student_id"], :name => "index_studyplan_items_on_student_id"
  add_index "studyplan_items", ["studyplan_id"], :name => "index_studyplan_items_on_studyplan_id"

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "phone"
    t.string   "email"
    t.integer  "dtu_teacher_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

end
