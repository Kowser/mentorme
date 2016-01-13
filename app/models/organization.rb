class Organization < ActiveRecord::Base
  has_attached_file :hero_image, :styles => { :thumb => "100x100>" },
                    default_url: ActionController::Base.helpers.asset_path("missing/hero.png")
  has_attached_file :logo, :styles => { :thumb => "100x100>" },
                    default_url: ActionController::Base.helpers.asset_path("missing/logo.png")

  belongs_to :umbrella, class_name: Organization

  has_many :organizations_users, inverse_of: :organization, dependent: :destroy
  has_many :mentors,  -> { where(role: 'Mentor', organizations_users: { active: true }) }, through: :organizations_users, source: :user
  has_many :mentees,  -> { where(role: 'Mentee', organizations_users: { active: true }) }, through: :organizations_users, source: :user
  has_many :staff,    -> { where(role: 'Partner') }, through: :organizations_users, source: :user
  has_many :users,    -> { where.not(role: ['Partner', 'Admin']) }, through: :organizations_users, source: :user
  has_many :background_checks, through: :users
  has_many :partners, class_name: Organization, foreign_key: :umbrella_id
  has_many :matches
  has_many :check_ins, through: :matches
  has_many :goals, through: :matches
  has_many :ratings, through: :check_ins
  has_many :references, through: :mentors
  has_many :forms, class_name: CustomForm
  has_many :emails, class_name: CustomEmail
  has_many :enrollments
  has_many :notes
  has_many :steps, through: :enrollments
  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: lambda { |attachment| attachment[:document].blank? }
  accepts_nested_attributes_for :organizations_users, allow_destroy: true

  validates :role, presence: true
  validates :name, presence: true
  validates :phone_number, presence: true
  validates :contact_email, presence: true
  validates :notification_email, presence: true
  validates :address1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true
  validates :about_us, presence: true

  validates_attachment_content_type :logo, :content_type => %w(image/png image/jpeg image/jpg image/gif)
  validates_attachment_content_type :hero_image, :content_type => %w(image/png image/jpeg image/jpg image/gif)

  def can_match_mentors
    mentors.where(organizations_users: { can_match: true, background_passed: [true, self.use_background_checks] }).order(:first_name, :last_name)
  end

  def can_match_mentees
    mentees.where(organizations_users: { can_match: true }).order(:first_name, :last_name)
  end

  def copy_enrollments(new_org_id)
    new_org = Organization.find(new_org_id)

    # copies ALL custom forms to destination Organization
    forms.each do |form| 
      new_form = new_org.forms.build(title: form.title)
      form.questions.each do |q|
        new_form.questions.new(q.attributes.except('id', 'form_id'))
      end
      new_form.save(validate: false)
    end

    # copies ALL custom emails to destination Organization
    emails.each do |email|
      new_email = new_org.emails.new(email.attributes.except('id', 'organization_id', 'recipient_misc', 'recipient_staff', 'recipient_user'))
      new_email.save(validate: false)
    end

    # copies ALL custom enrollments to destination Organization
    enrollments.each do |enrollment|
      new_enrollment = new_org.enrollments.build(user_type: enrollment.user_type, active: false)
      enrollment.steps.each do |step|
        new_enrollment.steps.new(step.attributes.except('id', 'enrollment_id', 'form_id', 'prerequisite_step_id', 'email_id', 'notification'))
      end
      new_enrollment.save(validate: false)
    end
  end

  def is_umbrella?
    role == 'Umbrella'
  end

  def is_partner?
    role == 'Partner'
  end

  def template_fields(role)
    template_fields = {}
    steps.where(step_type: 'template', enrollments: { active: true, user_type: [role, 'all'] }).each do |step|
      template_fields[step.template] = step.template_fields
    end
    template_fields
  end

  def user_applications(user)
    form_ids = steps.joins(:enrollment).where(step_type: 'custom', enrollments: { user_type: [user.role.downcase, 'all'] }).pluck(:form_id)
    form_ids += self.forms.where.not(id: form_ids).where(id: user.responses.pluck(:form_id)).pluck(:id)
    #adds inactive (former) applications/forms that are no longer used, but should still show up in Staff's view of user
    form_ids += umbrella.user_applications(user) if umbrella_id
    form_ids
  end

  def import_csv(file, role, password, user_notification)
    if role == "Match"
      import_matches(file)
    elsif ["Mentor", "Mentee"].include?(role)
      import_users(file, role, password, user_notification)
    else
      "Import Error: Please notify development team."
    end
  end

  # DASHBOARD METRICS ---------------------------------------
  PERIOD = {
    :week => Time.now.beginning_of_week,
    :month => Time.now.beginning_of_month
  }

  def unmatched(role_type)
    total = self.send(role_type).
            where("(SELECT count(*) FROM matches_users WHERE user_id = users.id) = 0").
            count
    partners.each { |partner| total += partner.unmatched(role_type) } if is_umbrella?
    total
  end

  def monthly_conversions(role_type)
    new_users = send(role_type).
                  joins(:organizations_users).
                  where(created_at: (Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month))
    new_matches = new_users.
                    where("(SELECT count(*) FROM matches_users WHERE user_id = users.id) > 0").
                    count
    (new_matches == 0 || new_users.count == 0) ? 0 : ((new_matches.to_f / new_users.count.to_f) * 100).round(1)
  end

  def alltime_conversions
    matched_mentors = mentors.where("(SELECT count(*) FROM matches_users WHERE user_id = users.id) > 0").count
    matched_mentees = mentees.where("(SELECT count(*) FROM matches_users WHERE user_id = users.id) > 0").count
    return matched_mentors, matched_mentees
  end

  def total_conversions
    total_mentors = mentors.count
    total_mentees = mentees.count
    (matched_mentors, matched_mentees) = alltime_conversions

    if is_umbrella?
      partners.each { |partner| total_mentors += partner.mentors.count }
      partners.each { |partner| total_mentees += partner.mentees.count }
      partners.each do |partner|
        (conv_mentors, conv_mentees) = partner.alltime_conversions
        matched_mentors += conv_mentors
        matched_mentees += conv_mentees
      end
    end

    conversions = {}
    conversions[:mentors] = total_mentors == 0 ? 0.to_f : ((matched_mentors.to_f / total_mentors.to_f) * 100).round(1)
    conversions[:mentees] = total_mentees == 0 ? 0.to_f : ((matched_mentees.to_f / total_mentees.to_f) * 100).round(1)
    conversions[:total] = (total_mentees + total_mentors) == 0 ? 0.to_f :
      (((matched_mentees + matched_mentors).to_f / (total_mentors + total_mentees).to_f) * 100).round(1)
    conversions
  end

  def signups(role_type, since)
    total = send(role_type).joins(:organizations_users).where(created_at: (PERIOD[since]..Time.now)).count
    partners.each { |partner| total += partner.signups(role_type, since) } if is_umbrella?
    total
  end

  def new_check_ins(role_type, since)
    total = send(role_type).
            where(["(SELECT count(*) FROM check_ins INNER JOIN check_ins_users ciu ON check_ins.id = ciu.check_in_id AND ciu.user_id = users.id AND check_ins.date BETWEEN ? AND ?) > 0", PERIOD[since], Time.now]).
            count
    partners.each { |partner| total += partner.new_check_ins(role_type, since) } if is_umbrella?
    total
  end

  def unhappy_check_ins(role_type, since)
    total = check_ins.includes(ratings: :user).where(date: (PERIOD[since]..Date.today)).where("ratings.rating < 3").references(:ratings).where("users.role = '#{role_type.to_s.camelize}'").references(:users).count
    partners.each { |partner| total += partner.unhappy_check_ins(role_type, since) } if is_umbrella?
    total
  end

  def goals_completed(since)
    total = goals.where(verified: true, updated_at: (PERIOD[since]..Time.now)).count
    partners.each { |partner| total += partner.goals_completed(since) } if is_umbrella?
    total
  end
  # end DASHBOARD METRICS ---------------------------------------

  def self.send_dashboard_metrics
    all.each do |organization|
      OrganizationMailer.dashboard_metrics_email(organization).deliver
    end
  end

private
  def import_users(file, role, password, notification)
    errors = []
    index = 1
    new_password = password.blank? ? 'p4s5w0rD' : password

    begin
      CSV.foreach(file.path, headers: true) do |row|
        index += 1
        user_params = row.to_hash.delete_if { |k, v| v.nil? }
        next if user_params.blank? # skip if row is blank
        
        ou_params = {} 
        ou_params[:skip_notification] = true
        ou_params[:joined_date] = user_params["joined_date"]
        ou_params[:background_passed] = user_params["background_passed"]
        ou_params[:references_submitted] = user_params["references_submitted"]
        ou_params[:organization] = self

        if user = User.find_by(login: user_params['login']) # if user exists, create or update organizations_users
          user.organizations_users.where(organization: self).first_or_initialize.update(ou_params)
          errors << "Row #{index}: Existing #{role} added/updated."
          next
        end

        ['joined_date', 'background_passed', 'references_submitted'].each { |param| user_params.delete(param)}
        user_params[:role] = role
        user_params[:password] = new_password
        user_params[:password_confirmation] = new_password
        user = User.new(user_params)
        user.skip_confirmation!
        user.organizations_users.build(ou_params)

        if user.save
          user.send_reset_password_instructions if notification
        else
          errors << "Row #{index}: #{user.errors.full_messages.join(', ')}"
        end
      end
    rescue => error
      errors << "#{error}"
    end

    errors
  end

  def import_matches(file)
    errors = []
    index = 1

    CSV.foreach(file.path, headers: true) do |row|
      match_group = row.to_hash.delete_if { |k, v| v.nil? }
      index += 1

      if match_group.blank?
        next
      elsif match_group['staff_email'].nil?
        errors << "Row #{index}: Staff Member required"
      else
        match_params = {
          :organization => self,
          :mentor_ids => [],
          :mentee_ids => [],
          :staff => staff.find_by(login: match_group['staff_email'].downcase)
        }

        match_group.delete('staff_email')
        match_group.each_value do |login|
          login = login.delete("() .-") unless login.include?('@')

          if !user = User.find_by(login: login)
            errors << "Row #{index}: No user #{login}. Match not created."
            break
          elsif user.role == 'Mentor'
            match_params[:mentor_ids] << user.id
          elsif user.role == 'Mentee'
            match_params[:mentee_ids] << user.id
          end
        end
        match = Match.new(match_params)
        errors << "Row #{index}: #{match.errors.full_messages.join(', ')}" unless match.save
      end
    end
    errors
  end

end
