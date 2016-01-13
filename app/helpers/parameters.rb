module Parameters
  attachments = { :attachments_attributes => [:id, :description, :document, :user_id, :_destroy] }

  USER_PARAMS = :staff_update, :first_name, :last_name, :ethnicity_other,
    :id, :address1, :address2, :city, :state, :zip ,:cell_phone, :home_phone, :work_phone, :ethnicity, :photo, :email,
    :phone_preference, :gender, :birth_date, :referred_by, :referral_name, :guardian_name, :relation, :guardian_cell_phone,
    :guardian_phone_preference, :school, :grade, :provider_phone, :policy_number, :guardian_work_phone,
    :guardian_home_phone, :mentee_phone, :physician, :physician_phone, :provider,
    :employer_job_title, :employer_name, :employer_length, :employer_address1,
    :employer_address2, :employer_city, :employer_state, :employer_zip, :dream_vacation, :other,
    {
      :references_attributes => [:id, :name, :email, :phone, :relation, :user_id]
    }

  BACKGROUND_PARAMS = :first_name, :middle_name, :last_name, :email, :phone, :zipcode, :dob, :ssn, :driver_license_number, :driver_license_state, :validations,
    :user_id, :checkr, :signature, :report, :package

  STAFF_PARAMS =
    :first_name, :last_name, :login, :password, :password_confirmation, { :statuses_attributes => [:id, :completed, :step_id, :user_id],
    :organizations_users_attributes => [:id, :can_match, :tags, :organization_id, :background_passed, :active, :joined_date,
      :references_submitted, :partner_joined, :umbrella_joined, :skip_notification, :_destroy] }

  ORGANIZATION_PARAMS = :name, :role, :notification_email, :phone_number, :address1, :address2, :city, :state,
    :zip_code, :description, :url, :tbi_number, :about_us, :hero_image, :logo, :contact_email, :subdomain,
    :umbrella_id, :twitter_link, :fb_link, :use_references, :use_background_checks, attachments

  ORGANIZATIONS_USERS_PARAMS = :id, attachments

  ENROLLMENT_PARAMS = :title, :user_type, :active, :step,
    { :steps_attributes => [:id, :title, :step_type, :form_id, :email_id, :template, :prerequisite_step_id, :sequence, :quantity,
      :notification, :_destroy, :template_fields => [] ]}

  FORM_PARAMS = :title, :for, :active,
    { :questions_attributes => [:id, :question, :hint, :question_type, :required, :collection, :sequence, :_destroy] }

  GOAL_PARAMS = :title, :assignees, :completed, :verified, :deadline, :link
  
  EMAIL_PARAMS = :id, :subject, :body, :recipient_user, :recipient_misc, :author, :organization, :text_message,
    { :recipient_staff => [] }

  MATCH_PARAMS = :staff_id, :organization, :active, :_destroy, { :mentee_ids => [], :mentor_ids => [] }

  CHECK_IN_PARAMS = :length, :meeting_type, :location, :date, :goals, :next_date, :match_id,
    { :mentor_ids => [], :mentee_ids => [], :ratings_attributes => [:id, :rating, :notes, :user_id] }, attachments

  REFERENCE_PARAMS = :user_id, :name, :email, :phone, :relation, :describe_duties, :acquainted, :content, :contacted,
    :reliable, :follow_through, :uncomfortable_groups, :strengths, :improvement_areas, :url_token, :endorsement
end
