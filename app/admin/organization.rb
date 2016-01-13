ActiveAdmin.register Organization do
  config.per_page = 25

  filter :name
  filter :role, label: 'Organization Type', as: :select, collection: ['Partner', 'Umbrella']

  index do
    column :name
    column :role
    column 'Umbrella Org' do |organization|
      organization.umbrella ? organization.umbrella.name : '--'
    end
    column 'Staff' do |organization|
      organization.staff.count
    end
    column :phone_number
    column :contact_email
    column :notification_email
    column :subdomain
    column :tbi_number
    column 'Files' do |org|
      org.attachments.count
    end
    actions
  end

  form html: { multipart: true } do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Organization Staff' do
      f.has_many :organizations_users, for: [:organizations_users, f.object.organizations_users.joins(:user).where(users: { role: 'Partner' })], allow_destroy: true do |ou|
        ou.input :user, as: :select, collection: User.where(role: 'Partner'), include_blank: false
        ou.input :umbrella_joined, label: 'Umbrella joined date', as: :datepicker
        ou.input :partner_joined, label: 'Partner joined date', as: :datepicker
        ou.input :active, as: :select, include_blank: false
      end
    end

    f.inputs "Edit Organization Profile" do
      f.input :name
      f.input :role, as: :select, collection: ['Partner', 'Umbrella'], include_blank: false
      f.input :umbrella, label: 'Parent Organization (if applicable)', as: :select, collection: Organization.where(role: 'Umbrella')
      f.input :phone_number
      f.input :contact_email
      f.input :notification_email
      f.input :subdomain
      f.input :address1
      f.input :address2
      f.input :city
      f.input :state, as: :select, collection: Collections::STATE
      f.input :zip_code
      f.input :about_us
      f.input :url
      f.input :twitter_link
      f.input :fb_link
      f.input :tbi_number, label: "TBI Number"
      f.input :hero_image, as: :file,
              hint: f.image_tag(f.object.hero_image.url(:thumb))
      f.input :logo, as: :file,
              hint: f.image_tag(f.object.logo.url(:thumb)),
              required: false
    end

    f.inputs "Organization Preferences" do
      f.input :use_references, as: :radio, label: "References"
      f.input :use_background_checks, as: :radio, label: "Background Checks"
    end

    f.inputs "Attachments" do
      table_for organization.attachments do
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
        column "Delete" do |attachment|
          link_to('Delete', attachment, method: :delete, remote: true, data: {confirm: 'Are you sure?'})
        end
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

  permit_params Parameters::ORGANIZATION_PARAMS, :organizations_users_attributes => [:id, :user_id, :active, :joined_date, :_destroy]
end
