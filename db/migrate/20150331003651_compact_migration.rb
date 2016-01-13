class CompactMigration < ActiveRecord::Migration
	enable_extension "plpgsql"
	enable_extension "pg_trgm"

	create_table "active_admin_comments", force: true do |t|
	  t.string   "namespace"
	  t.text     "body"
	  t.string   "resource_id",   null: false
	  t.string   "resource_type", null: false
	  t.integer  "author_id"
	  t.string   "author_type"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	end

	add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
	add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
	add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

	create_table "attachments", force: true do |t|
	  t.integer  "attachable_id"
	  t.string   "description"
	  t.string   "document_file_name"
	  t.string   "document_content_type"
	  t.integer  "document_file_size"
	  t.datetime "document_updated_at"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.string   "attachable_type"
	  t.string   "uploaded_by"
	  t.integer  "user_id"
	  t.integer  "organization_id"
	end

	add_index "attachments", ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type", using: :btree

	create_table "background_checks", force: true do |t|
	  t.string   "signature"
	  t.string   "status"
	  t.string   "checkr"
	  t.integer  "user_id"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.string   "error_msg"
	  t.string   "package"
	end

	create_table "check_ins", force: true do |t|
	  t.decimal  "length",       precision: 4, scale: 2
	  t.string   "meeting_type"
	  t.date     "date"
	  t.date     "next_date"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.integer  "match_id"
	  t.string   "location"
	end

	create_table "check_ins_mentees", force: true do |t|
	  t.integer "check_in_id"
	  t.integer "mentee_id"
	end

	create_table "check_ins_mentors", force: true do |t|
	  t.integer "check_in_id"
	  t.integer "mentor_id"
	end

	create_table "check_ins_users", force: true do |t|
	  t.integer  "user_id"
	  t.integer  "check_in_id"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	end

	add_index "check_ins_users", ["check_in_id", "user_id"], name: "index_check_ins_users_on_check_in_id_and_user_id", using: :btree

	create_table "custom_emails", force: true do |t|
	  t.boolean  "recipient_user"
	  t.json     "recipient_staff"
	  t.string   "recipient_misc"
	  t.integer  "organization_id"
	  t.string   "subject"
	  t.text     "body"
	  t.string   "author"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.string   "text_message"
	end

	add_index "custom_emails", ["organization_id"], name: "index_custom_emails_on_organization_id", using: :btree

	create_table "custom_form_questions", force: true do |t|
	  t.integer  "form_id"
	  t.string   "question"
	  t.string   "hint"
	  t.string   "question_type"
	  t.boolean  "required",        default: true
	  t.text     "collection_old"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.json     "collection_old2"
	  t.text     "collection"
	  t.integer  "sequence"
	end

	add_index "custom_form_questions", ["form_id"], name: "index_custom_form_questions_on_form_id", using: :btree

	create_table "custom_form_responses", force: true do |t|
	  t.integer  "user_id"
	  t.integer  "form_id"
	  t.json     "response"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	end

	add_index "custom_form_responses", ["form_id"], name: "index_custom_form_responses_on_form_id", using: :btree
	add_index "custom_form_responses", ["user_id"], name: "index_custom_form_responses_on_user_id", using: :btree

	create_table "custom_forms", force: true do |t|
	  t.string   "title"
	  t.string   "author"
	  t.boolean  "active",          default: false
	  t.integer  "organization_id",                 null: false
	  t.string   "for"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	end

	create_table "enrollments", force: true do |t|
	  t.integer  "organization_id"
	  t.string   "user_type"
	  t.string   "title"
	  t.boolean  "active",          default: false
	  t.string   "author"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	end

	create_table "goals", force: true do |t|
	  t.integer  "match_id"
	  t.string   "title"
	  t.boolean  "completed",       default: false
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.boolean  "verified",        default: false
	  t.string   "assignees"
	  t.date     "deadline"
	  t.integer  "completed_by_id"
	  t.integer  "verified_by_id"
	end

	create_table "matches", force: true do |t|
	  t.text     "staff_notes"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.integer  "staff_id"
	  t.boolean  "active",          default: true
	  t.integer  "organization_id"
	end

	create_table "matches_mentees", id: false, force: true do |t|
	  t.integer  "match_id"
	  t.integer  "mentee_id"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	end

	create_table "matches_mentors", id: false, force: true do |t|
	  t.integer  "match_id"
	  t.integer  "mentor_id"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	end

	create_table "matches_users", force: true do |t|
	  t.integer  "user_id"
	  t.integer  "match_id"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	end

	add_index "matches_users", ["match_id", "user_id"], name: "index_matches_users_on_match_id_and_user_id", using: :btree

	create_table "mentees", force: true do |t|
	  t.integer  "user_id"
	  t.string   "guardian_name"
	  t.string   "relation"
	  t.string   "gender"
	  t.string   "birth_date"
	  t.string   "address1"
	  t.string   "address2"
	  t.string   "city"
	  t.string   "state"
	  t.string   "zip"
	  t.string   "guardian_cell_phone"
	  t.string   "guardian_home_phone"
	  t.string   "guardian_work_phone"
	  t.string   "guardian_phone_preference"
	  t.string   "school"
	  t.string   "grade"
	  t.string   "referred_by"
	  t.string   "distance"
	  t.string   "ethnicity"
	  t.text     "staff_notes"
	  t.string   "mentee_phone"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.boolean  "guardian_contract",         default: false
	  t.boolean  "guardian_orientated",       default: false
	  t.boolean  "mentee_contract",           default: false
	  t.boolean  "mentee_orientated",         default: false
	  t.string   "physician"
	  t.string   "physician_phone"
	  t.string   "provider"
	  t.string   "provider_phone"
	  t.string   "policy_number"
	  t.string   "photo_file_name"
	  t.string   "photo_content_type"
	  t.integer  "photo_file_size"
	  t.datetime "photo_updated_at"
	  t.boolean  "interviewed",               default: false
	  t.string   "dream_vacation"
	  t.json     "interests"
	  t.json     "five_words"
	  t.string   "describe_one_sentence"
	  t.text     "other"
	  t.json     "backgrounds"
	  t.json     "multilingual"
	  t.json     "support_goal"
	  t.json     "availability"
	  t.json     "mentoring_type"
	  t.json     "format_preference"
	  t.boolean  "will_commit_minimum"
	  t.boolean  "will_commit_weekly"
	  t.boolean  "will_interview_orientate"
	  t.boolean  "english_first_language"
	  t.string   "why_mentor"
	  t.boolean  "parent_enrolled"
	  t.boolean  "enrolled_before"
	  t.string   "referral_name"
	  t.boolean  "program_fee",               default: false
	end

	create_table "mentors", force: true do |t|
	  t.integer  "user_id"
	  t.string   "gender"
	  t.string   "birth_date"
	  t.string   "address1"
	  t.string   "address2"
	  t.string   "city"
	  t.string   "state"
	  t.string   "zip"
	  t.string   "ethnicity"
	  t.string   "education"
	  t.string   "employer_job_title"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.date     "verified_date"
	  t.string   "verified_by"
	  t.string   "cell_phone"
	  t.string   "home_phone"
	  t.string   "work_phone"
	  t.string   "phone_preference"
	  t.string   "referred_by"
	  t.string   "distance"
	  t.string   "will_allow_background_check"
	  t.boolean  "interviewed",                 default: false
	  t.string   "photo_file_name"
	  t.string   "photo_content_type"
	  t.integer  "photo_file_size"
	  t.datetime "photo_updated_at"
	  t.text     "staff_notes"
	  t.boolean  "orientated",                  default: false
	  t.boolean  "trained",                     default: false
	  t.boolean  "stewards_trained",            default: false
	  t.string   "program_preference"
	  t.boolean  "application_completed",       default: false
	  t.boolean  "references_completed",        default: false
	  t.string   "employer_name"
	  t.string   "employer_length"
	  t.string   "employer_address1"
	  t.string   "employer_address2"
	  t.string   "employer_city"
	  t.string   "employer_state"
	  t.string   "employer_zip"
	  t.string   "dream_vacation"
	  t.json     "interests"
	  t.json     "five_words"
	  t.json     "why_mentor"
	  t.json     "gain_mentor"
	  t.string   "describe_middle_school"
	  t.text     "other"
	  t.json     "backgrounds"
	  t.json     "prior_experience"
	  t.json     "multilingual"
	  t.json     "support_goal"
	  t.json     "availability"
	  t.json     "mentoring_type"
	  t.json     "format_preference"
	  t.json     "mentee_age_preference"
	  t.boolean  "will_commit_minimum"
	  t.boolean  "will_commit_weekly"
	  t.boolean  "will_interview_orientate"
	  t.boolean  "background_passed",           default: false
	  t.boolean  "english_first_language"
	  t.boolean  "background_completed",        default: false
	  t.string   "referral_name"
	end

	create_table "notes", force: true do |t|
	  t.text     "content"
	  t.integer  "staff_id"
	  t.integer  "notable_id"
	  t.string   "notable_type"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.integer  "organization_id"
	end

	add_index "notes", ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type", using: :btree

	create_table "organizations", force: true do |t|
	  t.string   "name"
	  t.string   "phone_number"
	  t.string   "address1"
	  t.string   "address2"
	  t.string   "city"
	  t.string   "state"
	  t.string   "zip_code"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.string   "url"
	  t.string   "notification_email"
	  t.string   "tbi_number"
	  t.string   "role"
	  t.string   "subdomain"
	  t.string   "hero_image_file_name"
	  t.string   "hero_image_content_type"
	  t.integer  "hero_image_file_size"
	  t.datetime "hero_image_updated_at"
	  t.string   "logo_file_name"
	  t.string   "logo_content_type"
	  t.integer  "logo_file_size"
	  t.datetime "logo_updated_at"
	  t.integer  "umbrella_id"
	  t.text     "about_us"
	  t.string   "contact_email"
	  t.string   "twitter_link"
	  t.string   "fb_link"
	  t.boolean  "use_references",          default: false
	  t.boolean  "use_background_checks",   default: false
	end

	create_table "organizations_users", force: true do |t|
	  t.integer  "organization_id"
	  t.integer  "user_id"
	  t.boolean  "active",               default: true
	  t.boolean  "umbrella_referral",    default: false
	  t.date     "xjoined_date"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.string   "tags"
	  t.boolean  "can_match"
	  t.date     "umbrella_joined"
	  t.date     "partner_joined"
	  t.boolean  "background_passed",    default: false
	  t.integer  "progress",             default: 0
	  t.boolean  "references_submitted", default: false
	end

	add_index "organizations_users", ["organization_id", "user_id"], name: "index_organizations_users_on_organization_id_and_user_id", unique: true, using: :btree

	create_table "ratings", force: true do |t|
	  t.integer  "rating"
	  t.text     "notes"
	  t.integer  "check_in_id"
	  t.integer  "ratable_id"
	  t.string   "ratable_type"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.integer  "user_id"
	end

	add_index "ratings", ["check_in_id"], name: "index_ratings_on_check_in_id", using: :btree
	add_index "ratings", ["ratable_id", "ratable_type"], name: "index_ratings_on_ratable_id_and_ratable_type", using: :btree
	add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

	create_table "references", force: true do |t|
	  t.string   "name"
	  t.string   "email"
	  t.string   "phone"
	  t.string   "relation"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.string   "url_token"
	  t.integer  "mentor_id"
	  t.text     "describe_duties"
	  t.string   "acquainted"
	  t.string   "reliable"
	  t.string   "follow_through"
	  t.text     "uncomfortable_groups"
	  t.text     "strengths"
	  t.text     "improvement_areas"
	  t.boolean  "completed",            default: false
	  t.text     "content"
	  t.boolean  "contacted",            default: false
	  t.integer  "user_id"
	end

	create_table "searches", force: true do |t|
	end

	create_table "statuses", force: true do |t|
	  t.integer  "step_id"
	  t.integer  "user_id"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.boolean  "completed"
	end

	add_index "statuses", ["step_id"], name: "index_statuses_on_step_id", using: :btree
	add_index "statuses", ["user_id"], name: "index_statuses_on_user_id", using: :btree

	create_table "steps", force: true do |t|
	  t.boolean  "active",               default: false
	  t.integer  "enrollment_id"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.string   "title"
	  t.integer  "form_id"
	  t.string   "template"
	  t.string   "notification"
	  t.json     "template_fields"
	  t.integer  "email_id"
	  t.integer  "prerequisite_step_id"
	  t.string   "step_type"
	  t.integer  "sequence"
	end

	add_index "steps", ["enrollment_id"], name: "index_steps_on_enrollment_id", using: :btree

	create_table "users", force: true do |t|
	  t.string   "email",                       default: "",    null: false
	  t.string   "encrypted_password",          default: "",    null: false
	  t.string   "reset_password_token"
	  t.datetime "reset_password_sent_at"
	  t.datetime "remember_created_at"
	  t.integer  "sign_in_count",               default: 0,     null: false
	  t.datetime "current_sign_in_at"
	  t.datetime "last_sign_in_at"
	  t.string   "current_sign_in_ip"
	  t.string   "last_sign_in_ip"
	  t.string   "confirmation_token"
	  t.datetime "confirmed_at"
	  t.datetime "confirmation_sent_at"
	  t.string   "unconfirmed_email"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.string   "old_name"
	  t.string   "phone",                       default: ""
	  t.string   "login",                       default: "",    null: false
	  t.integer  "organization_id"
	  t.string   "role"
	  t.string   "tags"
	  t.string   "guardian_name"
	  t.string   "relation"
	  t.string   "gender"
	  t.string   "birth_date_tmp"
	  t.string   "address1"
	  t.string   "address2"
	  t.string   "city"
	  t.string   "state"
	  t.string   "zip"
	  t.string   "guardian_cell_phone"
	  t.string   "guardian_home_phone"
	  t.string   "guardian_work_phone"
	  t.string   "guardian_phone_preference"
	  t.string   "school"
	  t.string   "grade"
	  t.string   "referred_by"
	  t.string   "distance"
	  t.string   "ethnicity"
	  t.string   "mentee_phone"
	  t.boolean  "guardian_contract",           default: false
	  t.boolean  "guardian_orientated",         default: false
	  t.boolean  "mentee_contract",             default: false
	  t.boolean  "mentee_orientated",           default: false
	  t.string   "physician"
	  t.string   "physician_phone"
	  t.string   "provider"
	  t.string   "provider_phone"
	  t.string   "policy_number"
	  t.string   "photo_file_name"
	  t.string   "photo_content_type"
	  t.integer  "photo_file_size"
	  t.datetime "photo_updated_at"
	  t.boolean  "interviewed",                 default: false
	  t.string   "dream_vacation"
	  t.json     "interests"
	  t.json     "five_words"
	  t.string   "describe_one_sentence"
	  t.text     "other"
	  t.json     "backgrounds"
	  t.json     "multilingual"
	  t.json     "support_goal"
	  t.json     "availability"
	  t.json     "mentoring_type"
	  t.json     "format_preference"
	  t.boolean  "will_commit_minimum"
	  t.boolean  "will_commit_weekly"
	  t.boolean  "will_interview_orientate"
	  t.boolean  "english_first_language"
	  t.json     "why_mentor"
	  t.string   "why_mentee"
	  t.boolean  "parent_enrolled"
	  t.boolean  "enrolled_before"
	  t.string   "referral_name"
	  t.boolean  "program_fee",                 default: false
	  t.string   "education"
	  t.date     "verified_date"
	  t.string   "verified_by"
	  t.string   "cell_phone"
	  t.string   "home_phone"
	  t.string   "work_phone"
	  t.string   "phone_preference"
	  t.string   "will_allow_background_check"
	  t.boolean  "orientated",                  default: false
	  t.boolean  "trained",                     default: false
	  t.boolean  "stewards_trained",            default: false
	  t.string   "program_preference"
	  t.boolean  "application_completed",       default: false
	  t.boolean  "references_submitted",        default: false
	  t.string   "employer_job_title"
	  t.string   "employer_name"
	  t.string   "employer_length"
	  t.string   "employer_address1"
	  t.string   "employer_address2"
	  t.string   "employer_city"
	  t.string   "employer_state"
	  t.string   "employer_zip"
	  t.json     "gain_mentor"
	  t.string   "describe_middle_school"
	  t.json     "prior_experience"
	  t.json     "mentee_age_preference"
	  t.boolean  "background_passed",           default: false
	  t.boolean  "background_completed",        default: false
	  t.date     "birth_date"
	  t.string   "first_name"
	  t.string   "last_name"
	  t.string   "ethnicity_other"
	end

	add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
	add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
	add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
end
