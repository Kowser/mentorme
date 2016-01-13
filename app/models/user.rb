class User < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  attr_accessor :staff_update, :validations, :template
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :authentication_keys => [:login]

  before_create :certify_user
  before_update :strip_login_field,                           if: -> { login_changed? }

  has_one :background_check
  has_many :staff_matches, foreign_key: :staff_id, class_name: Match
  has_many :goals, through: :matches
  has_many :references, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :responses, class_name: CustomFormResponse, dependent: :destroy
  has_many :organizations_users, inverse_of: :user, dependent: :destroy
  has_many :organizations, through: :organizations_users
  has_many :enrollments, -> (user) { where(user_type: [user.role.to_s.downcase, 'all'], active: true) }, through: :organizations
  has_many :steps, through: :enrollments, source: :steps
  has_many :form_steps, -> { where.not(step_type: 'boolean') }, through: :enrollments, source: :steps
  has_many :statuses, dependent: :destroy
  has_many :files, through: :organizations_users, source: :attachments
  has_many :uploads, class_name: Attachment
  has_many :notes, foreign_key: :staff_id
  has_many :mentees, -> { where(role: 'Mentee') }, through: :matches, source: :users
  has_many :mentors, -> { where(role: 'Mentor') }, through: :matches, source: :users
  has_and_belongs_to_many :matches
  has_and_belongs_to_many :check_ins
  has_attached_file :photo, styles: { thumb: "100x100>", square: "240x240>" },
                    default_url: Proc.new { |p| ActionController::Base.helpers.asset_path("missing/#{p.instance.gender ? p.instance.gender.downcase : 'male'}.png") }

  accepts_nested_attributes_for :organizations_users, allow_destroy: true
  accepts_nested_attributes_for :statuses, reject_if: lambda { |status| status[:completed].nil? }
  accepts_nested_attributes_for :references

  validates :first_name, length: { minimum: 2, message: 'Full name please' }
  validates :last_name, length: { minimum: 2, message: 'Full name please' }

  validates :login, presence: true, uniqueness: { case_sensitive: false }, format: { with: ::Rails.application.config.login_regexp }
  validates :organizations_users, presence: { message: 'must have 1 organization.' }
  validates :role, presence: { message: "Please select an option." }, if: Proc.new { |u| u.new_record? }
  validates_attachment_content_type :photo, content_type: %w(image/png image/jpeg image/jpg image/gif)

# ------------------------ START TEMPLATE VALIDATIONS ------------------------
  validate :profile_template,                                 if: -> { template == 'profile' && !staff_update }
  validates_presence_of :gender,                              if: -> { template == 'profile' }
  def profile_template
    validates_presence_of :ethnicity                          if validations.try(:include?, 'ethnicity')
    validates_presence_of :ethnicity_other                    if validations.try(:include?, 'ethnicity') && ethnicity == 'Other'
    validates_presence_of :birth_date,
      { message: 'Please check format' }                      if validations.try(:include?, 'birth_date')
    validates_presence_of :address1, :city, :state, :zip      if validations.try(:include?, 'address')
    validates_presence_of :phone_preference                   if validations.try(:include?, 'phone_preference')
    validates_presence_of :school                             if validations.try(:include?, 'school')
    validates_presence_of :grade                              if validations.try(:include?, 'grade')
  end

  validate :presence_of_phone,                                if: -> { template == 'profile' && !staff_update }
  def presence_of_phone
    unless cell_phone.present? || home_phone.present? || work_phone.present?
      errors.add :cell_phone, 'At least one phone is required'
      errors.add :home_phone, 'At least one phone is required'
      errors.add :work_phone, 'At least one phone is required'
    end
  end

  validate :employment_template,                              if: -> { template == 'employment' }
  def employment_template
    validates_presence_of :employer_name                      if validations.try(:include?, 'name')
    validates_presence_of :employer_address1,
                          :employer_city,
                          :employer_state,
                          :employer_zip                       if validations.try(:include?, 'address')
    validates_presence_of :employer_job_title                 if validations.try(:include?, 'title')
    validates_presence_of :employer_length                    if validations.try(:include?, 'length')
  end

  before_validation :add_reference_validations,               if: -> { template == 'references' }
  def add_reference_validations
    self.references.each { |ref| ref.validations = validations }
  end
  validates_associated :references,                           if: -> { template == 'references' }

  validate :guardian_template,                                if: -> { template == 'guardian' }
  def guardian_template
    validates_presence_of :guardian_name                      if validations.try(:include?, 'name')
    validates_presence_of :relation                           if validations.try(:include?, 'relation')
    validates_presence_of :address1,
                          :city,
                          :state,
                          :zip                                if validations.try(:include?, 'address')
    validates_presence_of :guardian_cell_phone                if validations.try(:include?, 'phone')
    validates_presence_of :guardian_home_phone                if validations.try(:include?, 'phone')
    validates_presence_of :guardian_work_phone                if validations.try(:include?, 'work_phone')
    validates_presence_of :guardian_phone_preference          if validations.try(:include?, 'phone_preference')
  end

  validate :physician_template,                               if: -> { template == 'physician' }
  def physician_template
    validates_presence_of :physician                          if validations.try(:include?, 'name')
    validates_presence_of :physician_phone                    if validations.try(:include?, 'phone')
    validates_presence_of :provider                           if validations.try(:include?, 'provider')
    validates_presence_of :provider_phone                     if validations.try(:include?, 'policy')
    validates_presence_of :policy_number                      if validations.try(:include?, 'insurance_phone')
  end
# ------------------------ END TEMPLATE VALIDATIONS ------------------------
  def name
    first_name + ' ' + last_name
  end

  def is_mentor?
    role == "Mentor"
  end

  def is_mentee?
    role == "Mentee"
  end

  def is_partner?
    role == "Partner"
  end

  def is_admin?
    role == "Admin"
  end

  def find_next_step
    next_step = nil
    completed_steps_ids = statuses.where(completed: true).pluck(:step_id)
    form_steps.where.not(id: completed_steps_ids).each do |step|
      unless step.prerequisite_step_id && !completed_steps_ids.include?(step.prerequisite_step_id)
        next_step = step
        break
      end
    end
    next_step
  end

  def template_fields(*role) # role is ignored when @current_profile is a user not organization
    template_fields = {}
    template_steps = steps.where(step_type: 'template')
    template_steps.pluck(:template).uniq.each do |template|
      template_fields[template] = template_steps.where(template: template).pluck(:template_fields).flatten.uniq
    end
    template_fields
  end

  def update_status(step, *skip) # update completed status
    statuses.where(step: step).first_or_initialize.update(completed: true)
    update_progress(step.organization) if skip.blank?
  end

  def update_progress(organization) # updates % in OU progress
    unless (enrollment_steps = self.enrollments.find_by(organization: organization).try(:steps)).blank?
      ou = organizations_users.find_by(organization: organization)
      steps_completed = statuses.where(completed: true, step_id: enrollment_steps.pluck(:id)).count
      steps_denominator = enrollment_steps.count
      if enrollment_steps.where(template: 'references').any?
        steps_denominator += 1
        steps_completed += 1 if ou.references_submitted?
      end
      progress = ((steps_completed.to_f / steps_denominator.to_f) * 100).round(0)
      ou.update(progress: progress)
    end
  end

  def enrolled(organization) # finds enrollment date based on current organization
    ou = organizations_users.find_by(organization: organization)
    (organization.is_partner? ? ou.partner_joined : ou.umbrella_joined).try(:strftime, "%B %e, %Y")
  end

  def preferred_phone
    send(phone_preference.downcase + '_phone') unless phone_preference.blank?
  end

  def next_check_in
    check_in_id = unrated_check_ins.first
    CheckIn.find_by(id: check_in_id)
  end

  def unrated_check_ins
    check_ins.reorder(date: :asc).pluck(:id) - ratings.pluck(:check_in_id)
  end

  def login_is_email?
    self.login.include?('@')
  end

  def self.to_csv(options = {})
    export_columns = ["first_name", "last_name", "id", "email", "last_sign_in_at", "phone", "active", "tags"]

    if options[:role] != "Mentee"
      export_columns += ["gender", "birth_date", "address1", "address2", "city",
        "state", "zip", "ethnicity", "education", "employer_job_title", "cell_phone",
        "home_phone",
        "work_phone", "phone_preference", "references_submitted", "employer_name",
        "employer_length", "employer_address1", "employer_address2",
        "employer_city", "employer_state", "employer_zip", "background_passed"]
    end

    if options[:role] != "Mentor"
      export_columns += ["guardian_name", "relation", "gender", "birth_date",
        "guardian_cell_phone", "guardian_home_phone", "guardian_work_phone",
        "guardian_phone_preference", "school", "grade", "mentee_phone", "physician",
        "physician_phone", "provider", "provider_phone", "policy_number"]
    end

    options.delete(:role)

    CSV.generate(options) do |csv|
      csv << export_columns
      all.each do |user|
        user_attributes = user.attributes.values_at(*export_columns)
        csv << user_attributes
      end
    end
  end

  # Override Devise method
  def email_required?
    false
  end

  # manual console method for production only to email users who have never logged in
  def self.reset_passwords
    User.where(last_sign_in_at: nil).where.not(confirmed_at: nil, role: ['Partner', 'Admin'])
      .select{ |user| user.login_is_email? }.each { |user| user.send_reset_password_instructions }
  end

  def send_confirmation_notification?
    confirmation_required? && !@skip_confirmation_notification && self.login.present?
  end

  def pending_any_confirmation
    if (!confirmed? || pending_reconfirmation?)
      yield
    else
      self.errors.add(:login, :already_confirmed)
      false
    end
  end

  def confirm!
    pending_any_confirmation do
      if confirmation_period_expired?
        self.errors.add(:login, :confirmation_period_expired,
          period: Devise::TimeInflector.time_ago_in_words(self.class.confirm_within.ago))
        return false
      end

      self.confirmation_token = nil
      self.confirmed_at = Time.now.utc

      saved = if self.class.reconfirmable && unconfirmed_email.present?
        skip_reconfirmation!
        self.login = unconfirmed_email
        self.unconfirmed_email = nil

        # We need to validate in such cases to enforce e-mail uniqueness
        save(validate: true)
      else
        save(validate: false)
      end

      after_confirmation if saved
      saved
    end
  end

  # Send confirmation instructions
  def send_confirmation_instructions
    unless @raw_confirmation_token
      generate_confirmation_token!
    end

    if login_is_email?
      opts = pending_reconfirmation? ? { to: unconfirmed_email } : { }
      send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
    else
      text_confirmation_instructions
    end
  end

  # Devise module Recoverable method
  def send_reset_password_instructions
    #token = set_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token = enc
    self.reset_password_sent_at = Time.now.utc
    self.save(validate: false)
    token = raw

    if login_is_email?
      send_devise_notification(:reset_password_instructions, token, {})
    else
      text_reset_password_instructions(token)
    end

    token
  end

private
  def certify_user
    staff_update ? skip_confirmation! : (raise 'Invalid Role' unless ['Mentor', 'Mentee'].include? role)
    login_is_email? ? self.email = login : strip_login_field
  end

  def strip_login_field
    self.login = login.delete("() .-") unless login_is_email?
  end

  # Twilio methods
  def text_confirmation_instructions
    Text.send_text(login,
      "Confirm your MentorMe account: http://#{ENV['APP_DOMAIN']}#{user_confirmation_path}?confirmation_token=#{@raw_confirmation_token}"
    )
  end

  def text_reset_password_instructions(token)
    Text.send_text(login,
      "Password reset link: http://#{ENV['APP_DOMAIN']}/users/password/edit?reset_password_token=#{token}"
    )
  end
end
