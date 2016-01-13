class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :user_attributes, if: :user_signed_in?
  before_action :guest_attributes, unless: :user_signed_in?
  before_action :authenticate_user!
  before_action :show_selector, only: [:index], unless: :devise_controller?
  around_filter :append_event_tracking_tags

  def mixpanel_name_tag
    current_user && current_user.email
  end

  def after_sign_in_path_for(user)
    track_event("user login", role: user.role)
    if user.is_admin?
      admin_dashboard_path
    elsif user.is_partner?
      user_attributes #DO NOT REMOVE, else @current_profile won't be defined
      organization_dashboard_path(@current_profile)
    else
      user_path(user)
    end
  end

  def after_update_path_for(user)
    after_sign_in_path_for(user)
  end

  def authenticate_admin_user!
    authenticate_user!
    unless current_user.is_admin?
      flash[:alert] = "This area is restricted to administrators only."
      redirect_to root_path
    end
  end

private

  def user_attributes
    unless current_user.is_admin?

      if current_user.is_partner?
        @organization = Organization.includes(matches: [:check_ins, :goals, :ratings, :notes]).find(current_user.organizations.first.id)
        @current_profile = @organization.partners.find_by(id: params[:organization_id] || params[:id]) || @organization
      else # mentors & mentees
        @current_profile = current_user
        # some methods (ie: .matches, .check-ins) belong to both users and orgs. @current_profile allows one variable
        # to be used instead of current_user or 'current organization' depending on who is logged in.
      end
    end
  end

  def guest_attributes
    org_subdomain = request.subdomain.present? ? request.subdomain.downcase : 'www'
    unless @organization = Organization.find_by("lower(subdomain) = ?", org_subdomain) #loads organization for new users to sign up with
      flash[:alert] = "No such organization (#{org_subdomain})."
      redirect_to root_url(:host => request.domain + request.port_string)
    end
  end

  def find_user # Users, Responses controllers
    if current_user.is_partner?
      @user = @current_profile.users.find_by(id: params[:user_id] || params[:id])
    else
      @user = current_user
    end
  end

  def show_selector
    @show_selector = true if current_user.try(:is_partner?) && @organization.is_umbrella?
  end

  def authenticate_partner!
    redirect_to root_path unless current_user.is_partner?
  end

  def authenticate_mentor!
    redirect_to root_path unless current_user.is_mentor?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:first_name, :last_name, :role, :login, :password, :password_confirmation, :organizations_users_attributes => [:organization_id, :user]) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) << [:first_name, :last_name, :login, :password, :password_confirmation, :current_password]
  end

  def search_params
    params.require(:search).permit!
  end

  def alert_message(object)
    "<u>REQUIRED:</u><br>#{object.errors.full_messages.join('<br>')}".html_safe
  end

  def fix_errors_message(object)
    "<u>Please fix the errors below:</u><br>#{object.errors.full_messages.join('<br>')}".html_safe
  end
end
