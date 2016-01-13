ActiveAdmin.register CustomForm do
  menu parent: "Onboarding Process", label: "Applications", priority: 2
  config.per_page = 25
  
  filter :organization, as: :select, collection: Organization.order(:name)

  index do
    selectable_column
    column :organization
    column :title
    column 'Questions' do |form|
      form.questions.count
    end
    column 'Responses' do |form|
      form.responses.count
    end
    column :author
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Application' do
      f.input :organization
      f.input :title
    end

    f.inputs "Questions" do
      f.has_many :questions, allow_destroy: true do |q|
        q.input :sequence, label: 'Question Order', as: :select, collection: (1..100).to_a
        q.input :question
        q.input :hint, label: "Question Hint (optional)", hint: "This sentence is an example of a hint"
        q.input :collection, as: :text, label: "Leave blank if 'Question Type' is Text, otherwise separate with ;", hint: "Hint: Hit return after semi-colon for a cleaner list.", input_html: { rows: 6, value: q.object.answer_set }
        q.input :question_type, as: :select, label: 'Question Type', collection: [["Text (Written)", "text"], ["Select (drop down)", "select"], ["Radio (choose one)", "radio"], ["Check Boxes (multi-select)", "check_boxes"]], include_blank: '-- Choose --'
        q.input :required, as: :select, label: "Question required?", include_blank: false
      end
    end

    f.actions
  end

  permit_params Parameters::FORM_PARAMS, :organization_id
end