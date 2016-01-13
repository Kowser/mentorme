ActiveAdmin.register CustomEmail do
  menu parent: "Onboarding Process", label: "Emails", priority: 1
  config.per_page = 25
  
  filter :organization, as: :select, collection: Organization.order(:name)
  filter :recipient_user, label: 'Mentor/Mentee recipient?', collection: [['Yes', true],['No', false]], include_blank: true

  index do
    selectable_column
    column :organization
    column :subject
    column 'Recipients' do |email|
      email.recipient_count
    end
    column :author
    column :updated_at
    actions
  end

  form html: { multipart: true } do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Email' do
      f.input :organization
      f.input :recipient_staff, as: :select, multiple: true, input_html: { size: 15 }, label: 'Staff', collection: User.where(role: 'Partner').order(:first_name, :last_name),
        hint: "Hold 'CTRL' or 'COMMAND' to multi-select"
      f.input :recipient_user, as: :select, label: 'Include: Mentor / Mentee?'
      f.input :recipient_misc, as: :string, label: 'Additional emails, separate with ;'
      f.input :subject, label: 'Subject', placeholder: 'Profile complete! Next Step: Orientation'
      f.input :body, label: 'Body', input_html: { rows: 6 }
      f.input :text_message, label: 'Text Message', input_html: { rows: 2 }
    end

    f.actions
  end

  permit_params Parameters::EMAIL_PARAMS, :organization_id
end