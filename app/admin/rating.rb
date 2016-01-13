ActiveAdmin.register Rating do
  menu parent: "Matches & More..."
  config.per_page = 50
  actions :all, except: [:show, :edit, :new]

    index do
    selectable_column
    column 'Date' do |rating|
      rating.created_at.try(:strftime, "%m/%d/%Y")
    end
    column :user
    column "Check In", :check_in
    column :rating
    column :notes
    actions
  end

  filter :user_first_name, as: :string, label: "User's first name"
  filter :user_last_name, as: :string, label: "User's last name"
  filter :rating
end
