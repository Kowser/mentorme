class OrganizationMailer < ActionMailer::Base
  default from: "MentorMe, Inc. <support@getmentorme.com>", bcc: "Brit Fitzpatrick <brit@getmentorme.com>"

  def new_user_registered_email(user, organization)
    @user = user
    @organization = organization
    mail(to: "<#{@organization.notification_email}>", subject: "New #{@user.role} has registered!")
  end

  def new_user_assigned_email(user, organization)
    @user = user
    @organization = organization
    mail(to: "<#{@organization.notification_email}>", subject: "New #{@user.role} has been assigned!")
  end

  def references_submitted_email(user, organization)
    @user = user
    @organization = organization
    mail(to: "<#{@organization.notification_email}>", subject: "Mentor references submitted!")
  end

  def goal_completed_email(goal)
    @goal = goal
    @organization = goal.match.organization
    @staff = @goal.match.staff
    mail(to: "#{@staff.name} <#{@staff.email}>", subject: "#{@goal.title} is completed")
  end

  def low_rating_email(rating)
    @rating = rating
    @user = rating.user
    @staff = rating.check_in.match.staff
    @organization = rating.check_in.organization
    mail(to: "#{@staff.name} <#{@staff.email}>", subject: "Uh, oh! An unhappy Check-In")
  end

  def dashboard_metrics_email(organization)
    @organization = organization
    mail(to: "<#{organization.notification_email}>", subject: "Dashboard Metrics")
  end

  def step_completed_email(addressee, email, organization)
    @email = email
    @organization = organization
    mail(to: "<#{addressee}>", subject: email.subject,
      template_path: 'shared_mailer',
      template_name: 'step_completed_email')
  end

  def dev_team_email(msg)
    @organization = Organization.find_by(subdomain: 'www')
    @message = msg
    mail(to: "Dev Team <michal@getmentorme.com>", subject: "Dev Team Notification")
  end

end
