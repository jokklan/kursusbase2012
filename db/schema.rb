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

ActiveRecord::Schema.define(:version => 20120229104705) do

  create_table "course_relations", :force => true do |t|
    t.integer  "course_id"
    t.integer  "req_course_id"
    t.integer  "req_course_no"
    t.string   "prerequisite"
    t.string   "req_course_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "course_relations", ["course_id"], :name => "index_course_prerequisites_on_course_id"
  add_index "course_relations", ["req_course_id"], :name => "index_course_prerequisites_on_req_course_id"

  create_table "course_types", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "courses", :force => true do |t|
    t.integer  "course_number"
    t.string   "title"
    t.string   "language"
    t.float    "ects_points"
    t.boolean  "open_education"
    t.string   "schedule"
    t.string   "teaching_form"
    t.string   "duration"
    t.string   "participant_limit"
    t.text     "course_objectives"
    t.text     "learn_objectives"
    t.text     "content"
    t.string   "litteratur"
    t.string   "institute"
    t.string   "registration"
    t.string   "homepage"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "remarks"
    t.integer  "institute_id"
    t.string   "top_comment"
    t.string   "former_course"
    t.string   "exam_schedule"
    t.string   "exam_form"
    t.time     "exam_duration"
    t.string   "exam_aid"
    t.string   "evaluation_form"
  end

  create_table "courses_course_types", :force => true do |t|
    t.integer "course_type_id"
    t.integer "course_id"
  end

  create_table "courses_keywords", :force => true do |t|
    t.integer "keyword_id"
    t.integer "course_id"
  end

  create_table "courses_teachers", :force => true do |t|
    t.integer "teacher_id"
    t.integer "course_id"
  end

  create_table "institutes", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "keywords", :force => true do |t|
    t.string   "keyword"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "dtu_teacher_id"
  end

end
