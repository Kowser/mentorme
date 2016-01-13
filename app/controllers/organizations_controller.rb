class OrganizationsController < ApplicationController
  before_action :authenticate_partner!
  before_action :show_selector, only: [:show, :staff, :import, :background_checks]

  def staff
    add_breadcrumb "STAFF MEMBERS"
  end

  def new_staff_form
    add_breadcrumb "STAFF MEMBERS", :organization_staff_path
    add_breadcrumb "New Staff"
  end

  def create_staff
    @staff = User.new(staff_params.merge(role: 'Partner', staff_update: true))
    @staff.organizations_users.build(organization: @current_profile)
    if @staff.save
      flash[:success] = 'Team Member added!'
      redirect_to organization_staff_path(@current_profile)
    else
      flash.now[:alert] = fix_errors_message(@staff)
      add_breadcrumb "STAFF", :organization_staff_path
      add_breadcrumb "New Staff"
      render 'new_staff_form'
    end
  end

  def show
    @orgs = [@current_profile] + @current_profile.partners.order(:name)
    add_breadcrumb "DASHBOARD"
  end

  def edit
    add_breadcrumb "ORGANIZATION > Edit"
  end

  def update
    if @organization.update(organization_params)
      flash[:success] = "Organization Updated"
      redirect_to :back
    else
      flash.now[:alert] = fix_errors_message(@organization)
      add_breadcrumb "ORGANIZATION > Edit"
      render 'edit'
    end
  end

  def update_user
    @user = @current_profile.users.find(params[:id])
    if @user.update(staff_params)
      @user.update_progress(@current_profile)
      flash[:success] = "Update(s) successful"
    else
      flash[:alert] = fix_errors_message(@user)
    end

    if @current_profile.is_partner? || staff_params[:organizations_users_attributes]['0']['organization_id'].to_i == @current_profile.id # go back to profile view
      redirect_to organization_user_path(@current_profile, @user)
    else # go back to Mentor/Mentee index if user moved to another org
      redirect_to organization_users_path(@current_profile, search: { role: @user.role } )
    end
  end

  def update_users
    status_params = staff_params["statuses_attributes"].values.reject { |v| v['completed'].nil? } if staff_params["statuses_attributes"]
    ou_params = staff_params["organizations_users_attributes"].values.first.delete_if { |k, v| v.blank? }

    if params[:user_ids].blank?
      flash[:alert] = "Please check users to update."
    elsif status_params.blank? && ou_params.blank?
      flash[:alert] = "Please select updates."
    else
      users = User.find(params[:user_ids])
      users.each do |user|
        user.organizations_users.find_by(organization: @current_profile).update(ou_params) unless ou_params.blank?
        status_params.each do |status|
          user.statuses.where(step_id: status['step_id'].to_i).first_or_initialize.update(status)
        end unless status_params.blank?
      end
      flash[:success] = "Update(s) completed"
    end
    redirect_to :back
  end

  def preferences
    add_breadcrumb "PREFERENCES > Edit"
  end

  def import
    add_breadcrumb "IMPORTS"
  end

  def import_csv
    if !params[:password].blank? && params[:password].length < 8
      flash.now[:alert] = "Minimum password length is 8 characters"
    elsif !params[:file]
      flash.now[:alert] = "Please attach a file"
    elsif params[:role].blank?
      flash.now[:alert] = "You must choose a type"
    else
      errors = @current_profile.import_csv(params[:file], params[:role], params[:password], params[:notification])
      errors.empty? ? flash.now[:notice] = "Imported: No errors" :
                      flash.now[:alert] = "Imported: With errors"
                      flash.now[:alert] =  errors
    end
    add_breadcrumb "IMPORTS"
    render 'import'
  end

private
  def staff_params
    params.require(:user).permit(Parameters::STAFF_PARAMS)
  end

  def organization_params
    params.require(:organization).permit(Parameters::ORGANIZATION_PARAMS)
  end
end
