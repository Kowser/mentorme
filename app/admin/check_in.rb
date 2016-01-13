ActiveAdmin.register CheckIn do
  menu parent: "Matches & More..."
  config.per_page = 25
  actions :all, except: [:new]

  filter :organization, as: :select, collection: Organization.order(:name)
  filter :users_first_name, as: :string, label: "User's first name"
  filter :users_last_name, as: :string, label: "User's last name"
  filter :date
  filter :next_date
  filter :meeting_type, as: :select, collection: Collections::CHECK_IN_MEETING_TYPE
  filter :length, label: "Duration (ie: 1.25, or 2)"

  index do
    selectable_column
    column :date
    column "Duration", :length
    column :next_date
    column :meeting_type
    column "Rated" do |check_in|
      check_in.ratings.pluck(:rating).join(",")
    end
    column 'Files' do |check_in|
      check_in.attachments.count
    end
    actions
  end

  form html: { multipart: true } do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Edit Check-In" do
      f.input :mentors, as: :check_boxes, label: 'Mentors', collection: check_in.match.try(:mentors)
      f.input :mentees, as: :check_boxes, label: 'Mentees', collection: check_in.match.try(:mentees)
      f.input :date, label: "Check-In Date"
      f.input :length, label: "Lasted (Hours)", as: :select, collection: Collections::CHECK_IN_LENGTH
      f.input :next_date
      f.input :meeting_type, as: :select, collection: Collections::CHECK_IN_MEETING_TYPE, label: "How did you meet?"
      f.input :location, label: "Where did you meet? (Required if 'In Person')"
    end

    f.inputs "Ratings" do
      table_for check_in.ratings do
        column "Date" do |rating|
          rating.updated_at.try(:strftime, "%m/%d/%Y")
        end
        column "User", :user
        column "Rating", :rating
        column "Tell us more about what you did", :notes
      end
    end

    f.inputs "Attachments" do
      table_for check_in.attachments do
        column "Date" do |attachment|
          attachment.created_at.try(:strftime, "%m/%d/%Y")
        end
        column "Uploaded By" do |attachment|
          attachment.user.try(:name)
        end
        column "File name" do |attachment|
          link_to("#{attachment.document_file_name}", attachment.document.url)
        end
        column "description", :description
      end

      f.has_many :attachments do |attachment|
        if attachment.object.new_record?
          attachment.input :document, as: :file, required: false
          attachment.input :description, label: "#{attachment.object.name.to_s.camelize}"
          attachment.input :_destroy, as: :boolean, label: "Delete"
          attachment.input :user_id, as: :hidden, input_html: {value: current_user.id }
        end
      end
    end

    f.actions
  end

  permit_params Parameters::CHECK_IN_PARAMS
end
