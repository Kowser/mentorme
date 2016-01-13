ActiveAdmin.register Enrollment do
  menu parent: "Onboarding Process", label: 'Enrollments', priority: 3
  config.per_page = 25
  actions :all, except: [:show, :new]

  filter :organization, as: :select, collection: Organization.order(:name)
  filter :active

  index do
    selectable_column
    column :organization
    column "" do |enrollment|
      Collections::USER_TYPES[enrollment.user_type]
    end
    column :active
    column 'Steps' do |enrollment|
      enrollment.steps.count
    end
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Enrollment' do
      f.input :organization
      f.input :user_type, as: :select, label: "Who is this onboarding process for?", collection: Collections::USER_TYPES.invert, include_blank: "- Select -"
      f.input :active, as: :select, label: "Onboarding process is live?", include_blank: false
    end

    f.inputs "Steps" do
      table_for enrollment.steps do
        column 'Order', :sequence
        column :step_type
        column 'Step Title', :title
        column 'Template / Form' do |step|
          step.form.try(:title) || step.template.try(:humanize)
        end
        column 'Email (Subject)' do |step|
          step.email.try(:subject)
        end
      end
    end

    f.actions
  end

  permit_params Parameters::ENROLLMENT_PARAMS, :organization_id
end
