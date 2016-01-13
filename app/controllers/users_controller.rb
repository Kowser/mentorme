class UsersController < ApplicationController
  before_action :authenticate_partner!, only: [:index]
  before_action :find_user, except: [:index]
  require 'will_paginate/array'

  def role_name
    params[:search].try(:[], :role)
  end

  def index
    respond_to do |format|
      format.html {
        @search = params[:search] ? Search.new(search_params) : Search.new
        @users = Search.users(@current_profile, params[:search]).paginate(page: params[:page], per_page: 35)
        @enrollments = @current_profile.enrollments.where(user_type: [role_name.try(:downcase), 'all'])
        add_breadcrumb "#{role_name.try(:upcase)}S"
      }

      format.csv {
        if params[:user_ids].blank?
          user_ids = Search.users(@current_profile, params[:search]).pluck(:id)
        else
          user_ids = params[:user_ids].split(',')
        end

        filename = @current_profile.name.parameterize + "_" + (role_name || "user").pluralize.parameterize
        response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}.csv\""
        render text: User.where(id: user_ids).to_csv(role: role_name)
      }
    end
  end

  def show
    if current_user.is_partner?
      @enrollments = @user.enrollments.where(organization_id: @current_profile.id)
      form_ids = @current_profile.user_applications(@user)
      add_breadcrumb "#{@user.role.try(:upcase)}S", organization_users_path(search: {role: @user.role})
      add_breadcrumb "#{@user.name}", organization_user_path(@current_profile, @user)
    else
      add_breadcrumb "PROFILE", user_path(current_user)
      check_step_progress
      @enrollments = current_user.enrollments
      form_ids = current_user.responses.pluck(:form_id)
    end
    @template_fields = @current_profile.template_fields(@user.role.downcase)
    @applications = CustomForm.where(id: form_ids)
    @responses = @user.responses.where(form_id: form_ids)
  end

  def edit_templates
    if current_user.is_partner?
      enrollment_id = @user.enrollments.find_by(organization_id: @current_profile.id).id
      @step = @current_profile.steps.where(template: params[:template]).find_by(enrollment_id: enrollment_id)
      add_breadcrumb "#{@user.role.try(:upcase)}S", organization_users_path(search: {role: @user.role})
      add_breadcrumb "#{@user.name}", organization_user_path(@current_profile, @user)
    else
      add_breadcrumb "PROFILE", user_path(current_user)
      @step = consolidated_step
    end
    add_breadcrumb "Edit #{@step.template.titlecase}"
    render "enrollments/template_forms/#{@step.template}"
  end

  def update # only affects templates
    @step = @user.steps.find_by(id: params[:step_id]) || consolidated_step
    if @user.update(user_params.merge(template: @step.template, validations: @step.template_fields))
      track_event(
        "user completed step",
        user_id: @user.id,
        response_id: nil,
        role: @user.role,
        template: @step.template,
        step_id: @step.id
      ) unless @step.new_record?
      @user.update_status(@step) unless @step.new_record?
      flash[:success] = @step.try(:notification).try(:present?) ? @step.notification : 'Saved! Thank you!'
      redirect_to action: 'show'
    else
      add_breadcrumb "PROFILE", user_path(@user) unless current_user.is_partner?
      add_breadcrumb "#{@user.role.try(:upcase)}S", organization_users_path(search: {role: @user.role}) if current_user.is_partner?
      add_breadcrumb "#{@user.name}", organization_user_path(@current_profile, @user) if current_user.is_partner?
      add_breadcrumb "Edit #{@step.template.titlecase}"
      render "enrollments/template_forms/#{@step.template}"
    end
  end

private
  def consolidated_step
    template_fields = @user.steps.where(template: params[:template]).pluck(:template_fields).flatten.uniq
    quantity = @user.steps.where(template: params[:template]).pluck(:quantity).max if params[:template] == 'references'
    Step.new(template: params[:template], template_fields: template_fields, quantity: quantity )
  end

  def check_step_progress
    if @step = current_user.find_next_step
      case @step.step_type
      when 'custom'
        redirect_to new_user_custom_form_response_path(current_user, step_id: @step.id, form_id: @step.form_id)
      when 'template'
        add_breadcrumb "#{@step.organization.name} > #{@step.template.titlecase}"
        render "enrollments/template_forms/#{@step.template}"
      end
    end
  end

  def user_params
    params.require(:user).permit(Parameters::USER_PARAMS)
  end

end
