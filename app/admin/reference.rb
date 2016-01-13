ActiveAdmin.register Reference do
  config.per_page = 50
  actions :all, except: [:show, :new]

  filter :user_first_name, as: :string, label: "Mentor's first name"
  filter :user_last_name, as: :string, label: "Mentor's last name"
  filter :completed, as: :select, collection: [["Yes", true],["No", false]]
  filter :name, label: 'Reference name'
  filter :url_token
  filter :created_at

  index do
    column 'Mentor', :user
    column "Reference's Name", :name
    column :url_token
    column 'Created On', :created_at
    column :completed
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    user_name = reference.user.try(:name)
    f.inputs 'Reference Profile' do
      f.input :user, label: "Reference for (Read Only):", as: :string,
        input_html: { value: f.object.user.name, readonly: true }
      f.input :name
      f.input :email
      f.input :phone
      f.input :relation
      f.input :url_token, input_html: { readonly: true }
    end

    f.inputs 'Endorsement Form' do
      f.input :describe_duties, input_html: { rows: 4 }
      f.input :acquainted, label: "How long have you known #{user_name}?"
      f.input :reliable, as: :select, collection: ["Yes", "No"],
        label: "Do you consider #{user_name} to be reliable/punctual?"
      f.input :follow_through, as: :select, collection: ["Yes", "No"],
        label: "Does #{user_name} follow tasks through to completion?"
      f.input :uncomfortable_groups, input_html: { rows: 4 }
      f.input :strengths, input_html: { rows: 4 }
      f.input :improvement_areas, input_html: { rows: 4 }
      f.input :content, input_html: { rows: 4 }
    end
    f.actions
  end

  permit_params Parameters::REFERENCE_PARAMS
end

