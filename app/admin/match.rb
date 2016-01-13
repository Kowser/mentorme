ActiveAdmin.register Match do
  menu parent: "Matches & More..."
  config.per_page = 25
  actions :all, except: [:show, :new]

  index do
    selectable_column
    column 'Mentors' do |match|
      table_for match.mentors do
        column { |mentor| mentor.name }
      end
    end

    column 'Mentees' do |match|
      table_for match.mentees do
        column { |mentee| mentee.name }
      end
    end

    column 'Check-Ins' do |match|
      match.check_ins.count
    end

    column 'Last Check-In' do |match|
      match.check_ins.last.try(:date)
    end

    column 'Staff Member', :staff
    column :organization
    actions
  end

  filter :users_first_name, as: :string, label: "User's first name"
  filter :users_last_name, as: :string, label: "User's last name"
  filter :organization, label: 'Partner Organizations', collection: Organization.where(role: 'Partner').order(:name)
  filter :staff_first_name, as: :string, label: "Staff first name"
  filter :staff_last_name, as: :string, label: "Staff last name"

  form do |f|
    f.inputs "Edit Match" do
      f.semantic_errors *f.object.errors.keys
      f.input :organization, label: 'Partner Organization', include_blank: false, collection: Organization.where(role: 'Partner').order(:name)
      f.input :staff, label: 'Staff', collection: match.organization.try(:staff).order(:first_name, :last_name)
      f.input :active, as: :select, label: 'Match active?', include_blank: false

      table_for match do
        column "Mentors" do
          f.input :mentors, as: :select, multiple: true, label: false, collection: match.organization.try(:can_match_mentors), input_html: { size: 25 }
        end
        column "Mentees" do
          f.input :mentees, as: :select, multiple: true, label: false, collection: match.organization.try(:can_match_mentees), input_html: { size: 25 }
        end
      end
    end

    f.inputs "Goals" do
      table_for match.goals do
        column "Title", :title
        column "Status" do |goal|
          'status'
        end
        column "Link" do |goal|
          goal.link.blank? ? "--" : (link_to "View", (goal.link.include?("http") ? goal.link : "#{'http://' + goal.link}"), target: '_blank')
        end
        column "Completed By" do |goal|
          goal.completed_by.try(:name)
        end
        column "Verified By" do |goal|
          goal.verified_by.try(:name)
        end
        column "Assigned On" do |goal|
          goal.created_at.strftime("%m/%d/%Y")
        end
        column "Deadline" do |goal|
          goal.deadline.try(:strftime, "%m/%d/%Y")
        end
        column "Delete" do |goal|
          link_to('Delete', goal, method: :delete, remote: true, data: {confirm: 'Are you sure?'})
        end
      end
    end

    f.inputs "Check-Ins" do
      table_for match.check_ins do
        column :date
        column "Next Check-In", :next_date
        column :meeting_type
        column :length
        column "Rated" do |check_in|
          check_in.ratings.map(&:rating).join(', ')
        end
        column "Attendees" do |check_in|
          check_in.users.map(&:name).join('; ')
        end
      end
    end

    f.actions
  end

  permit_params Parameters::MATCH_PARAMS, :goals_attributes => [:id, :match, :title, :completed, :verified, :_destroy]
end
