ActiveAdmin.register User do
  config.per_page = 50

  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end
  end

  index do
    selectable_column
    column 'Name', :name
    column :login
    column 'Login Confirmed' do |u|
      u.confirmed_at ? 'Yes' : 'No'
    end
    column 'Logins', :sign_in_count
    column :role
    column 'Organizations' do |user|
      user.organizations.pluck(:name).join('; ')
    end
    column 'Files' do |user|
      user.files.count
    end
    actions
  end

  filter :first_name
  filter :last_name
  filter :login
  filter :role, label: 'Role(s)', as: :select, multiple: true, collection: ['Mentor', 'Mentee', 'Partner', 'Admin']
  filter :organizations, as: :select, collection: Organization.order(:name)
  filter :organizations_users_active, label: 'Active (with Organization)', as: :select, collection: [['Yes', true],['No', false]]
  filter :last_sign_in_at

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'User Registration' do
      f.input :staff_update, as: :hidden, input_html: { value: true }
      f.input :first_name
      f.input :last_name
      f.input :login
      f.input :role, as: :select, collection: ['Mentor', 'Mentee', 'Partner', 'Admin'], include_blank: false
      f.input :password
      f.input :password_confirmation
    end

    f.inputs 'Organization History' do
      f.has_many :organizations_users, allow_destroy: true do |ou|
        ou.input :organization, as: :select, include_blank: false
        ou.input :active, as: :select
        ou.input :skip_notification, as: :select, collection: [['No', 'not_blank'], ['Yes', '']], include_blank: false, label: 'Notify user of new organization?'
        ou.input :joined_date, label: 'Organization signup date (leave blank for Today)', as: :datepicker, input_html: { value: ou.object.enrolled }
        ou.input :tags
        ou.input :can_match
      end
    end
    f.actions

    unless user.new_record?
      f.inputs 'Profile' do
        f.input :address1, label: "Street Address"
        f.input :address2, label: "Apartment/Unit Number"
        f.input :city
        f.input :state, as: :select, collection: Collections::STATE
        f.input :zip
        f.input :birth_date, as: :datepicker, label: 'Birth Date (mm-dd-yyyy)'
        f.input :cell_phone
        f.input :home_phone
        f.input :work_phone
        f.input :phone_preference, label: "Which phone number should we use to call you?", collection: ['Cell','Home','Work']
        f.input :gender, as: :radio, collection: ['Male','Female']
        f.input :ethnicity, label: 'What is your ethnicity?', collection: Collections::ETHNICITY
        f.input :ethnicity_other, label: 'Other - Please specifiy'
      end

      f.inputs 'Employment' do
        f.input :employer_name, label: "Employer Name"
        f.input :employer_job_title, label: "Job Title"
        f.input :employer_length, label: "Years with current employer"
        f.input :employer_address1, label: "Employer's address"
        f.input :employer_address2, label: "Employer's address, line 2"
        f.input :employer_city
        f.input :employer_state
        f.input :employer_zip
      end if user.is_mentor?

      f.inputs "References" do
        f.input :references_submitted, as: :select, label: 'References submitted:'
        table_for user.references do
          column :name
          column :phone
          column :email
          column :relation
        end
      end if user.is_mentor?

      f.inputs 'Guardian' do
        f.input :guardian_name, label: "Guardian's Name"
        f.input :relation, label: "What is your guardian's relationship to you?", placeholder: "Father / Mother / etc..."
        f.input :address1, label: "Street Address"
        f.input :address2, label: "Apartment/Unit Number"
        f.input :city
        f.input :state, as: :select, collection: Collections::STATE
        f.input :zip
        f.input :guardian_cell_phone, label: 'Cell phone'
        f.input :guardian_home_phone, label: 'Home phone'
        f.input :guardian_work_phone, label: 'Work phone'
        f.input :guardian_phone_preference, as: :select, collection: ['Cell','Home','Work'], label: "Which phone number should we use to call?"
      end if user.is_mentee?

      f.inputs 'Physician' do
        f.input :physician, label: "Who is your primary care physician?"
        f.input :physician_phone, label: "What is the physician's phone number?"
        f.input :provider, label: "Who is your medical insurance provider?"
        f.input :provider_phone, label: "What is the policy number?"
        f.input :policy_number, label: "What is the insurance provider's phone number?"
      end if user.is_mentee?

      f.actions
    end
  end

  permit_params Parameters::STAFF_PARAMS, Parameters::USER_PARAMS, :role, :references_submitted
end
