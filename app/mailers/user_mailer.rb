class UserMailer < Devise::Mailer
	default from: "MentorMe, Inc. <support@getmentorme.com>"
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def confirmation_instructions(record, token, opts={})
    @token = token
    @organization = Organization.find_by(subdomain: 'www')
    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, token, opts={})
    @token = token
    @organization = Organization.find_by(subdomain: 'www')
    devise_mail(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record, token, opts={})
    @token = token
    @organization = Organization.find_by(subdomain: 'www')
    devise_mail(record, :unlock_instructions, opts)
  end
  # end DEVISE emails -------------------------------------

  def new_partner_organization_email(user, organization)
    @user = user
    @organization = organization
    if user.login_is_email?
      mail(to: "#{user.name} <#{user.login}>", subject: "Welcome to your new partner organization!")
    else
      Text.send_text(user.login, "MentorMe: You've been assigned to a new partner organization!")
    end
  end

  def step_completed_email(user, email, organization)
    @email = email
    @organization = organization
    if user.login_is_email?
      mail(to: "#{user.name} <#{user.email}>",
        subject: email.subject,
        template_path: 'shared_mailer',
        template_name: 'step_completed_email')
    else
      Text.send_text(user.login, email.text_message)
    end
  end

  def reference_email(reference)
    @reference = reference
    @organization = reference.user.organizations.first
    mail(to: "#{reference.name} <#{reference.email}>", subject: "Reference request for #{reference.user.name}")
  end

  def completed_reference_email(reference)
    @reference = reference
    @user = reference.user
    @organization = reference.user.organizations.first
    if @user.login_is_email?
      mail(to: "#{@user.name} <#{@user.login}>", subject: "A reference has been completed")
    else
      Text.send_text(@user.login, "MentorMe: One of your references completed an endorsement.")
    end
  end

  def references_submitted_email(user)
    @user = user
    @organization = user.organizations.first
    if user.login_is_email?
      mail(to: "#{user.name} <#{user.login}>", subject: "All references submitted!")
    else
      Text.send_text(user.login, "MentorMe: All of your references have been submitted!")
    end
  end

  def new_match_email(user, organization)
    @organization = organization
    @user = user
    if user.login_is_email?
      mail(to: "#{user.name} <#{user.email}>",
        subject: "You've been matched!")
    else
      Text.send_text(user.login, "MentorMe: You've been matched! Login and see who it is...")
    end
  end

  def new_goal_email(user, organization)
    @organization = organization
    if user.login_is_email?
      mail(to: "#{user.name} <#{user.email}>", subject: "There's a new goal!")
    else
      Text.send_text(user.login, "MentorMe: There's a new goal! I wonder what it is...")
    end
  end

  def goal_verified_email(goal)
    @goal = goal
    @organization = goal.match.organization
    goal.match.mentors.each do |user|
      if user.login_is_email?
        mail(to: "#{user.name} <#{user.email}>", subject: "Congrats! Goal Verified")
      else
        Text.send_text(user.login, "Congrats! Goal '#{goal.title}' has been verified.")
      end
    end
  end
  
end