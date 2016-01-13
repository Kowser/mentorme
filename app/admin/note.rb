ActiveAdmin.register Note do
  config.per_page = 50
  actions :all, except: [:show, :new]

  filter :staff_first_name, as: :string
  filter :staff_last_name, as: :string
  filter :organization, as: :select, collection: Organization.order(:name)
  filter :content

  index do
    selectable_column
    column :content
    column 'Staff', :staff
    column 'Note for', :notable
    actions
  end

  form do |f|
    f.inputs "Edit Note" do
      f.semantic_errors *f.object.errors.keys
      f.input :staff, label: 'Staff', collection: note.organization.try(:staff)
      f.input :content
    end
  end
end
