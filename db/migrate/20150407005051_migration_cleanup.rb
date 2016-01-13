class MigrationCleanup < ActiveRecord::Migration
  # migration not active, sitting in storage folder
  def change
	  drop_table :check_ins_mentors
	  drop_table :check_ins_mentees
	  drop_table :matches_mentors
	  drop_table :matches_mentees
	  drop_table :mentors
	  drop_table :mentees
	  remove_column :attachments, :uploaded_by
	  remove_column :check_ins_users, :created_at
	  remove_column :check_ins_users, :updated_at
	  remove_column :organizations_users, :umbrella_referral
	  remove_column :organizations_users, :xjoined_date
	  remove_column :custom_forms, :active
	  remove_column :custom_forms, :for
	  remove_column :enrollments, :title
	  remove_column :ratings, :ratable_type
	  remove_column :ratings, :ratable_id
	  remove_column :custom_form_questions, :collection_old
	  remove_column :custom_form_questions, :collection_old2
	  remove_column :users, :old_name
	  remove_column :users, :tags
	  remove_column :users, :application_completed
	  remove_column :users, :organization_id
	  remove_column :users, :birth_date_tmp
	  remove_column :users, :distance
	  remove_column :users, :interviewed
	  remove_column :users, :dream_vacation
	  remove_column :users, :interests
	  remove_column :users, :five_words
	  remove_column :users, :describe_one_sentence
	  remove_column :users, :other
	  remove_column :users, :backgrounds
	  remove_column :users, :multilingual
	  remove_column :users, :support_goal
	  remove_column :users, :availability
	  remove_column :users, :mentoring_type
	  remove_column :users, :format_preference
	  remove_column :users, :will_commit_minimum
	  remove_column :users, :will_commit_weekly
	  remove_column :users, :will_interview_orientate
	  remove_column :users, :english_first_language
	  remove_column :users, :why_mentor
	  remove_column :users, :why_mentee
	  remove_column :users, :parent_enrolled
	  remove_column :users, :enrolled_before
	  remove_column :users, :referral_name
	  remove_column :users, :program_fee
	  remove_column :users, :education
	  remove_column :users, :will_allow_background_check
	  remove_column :users, :orientated
	  remove_column :users, :trained
	  remove_column :users, :stewards_trained
	  remove_column :users, :program_preference
	  remove_column :users, :gain_mentor
	  remove_column :users, :describe_middle_school
	  remove_column :users, :prior_experience
	  remove_column :users, :mentee_age_preference
	  remove_column :users, :background_completed
	  remove_column :users, :guardian_contract
	  remove_column :users, :guardian_orientated
	  remove_column :users, :mentee_contract
	  remove_column :users, :mentee_orientated
  end
end
