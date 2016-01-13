class EnrollmentsController < ApplicationController
	before_action :authenticate_partner!
	add_breadcrumb "CUSTOM ONBOARDING", :organization_enrollments_path, except: [:destroy, :form_select, :template_fields]

	def index
		@enrollments = @current_profile.enrollments
		@forms = @current_profile.forms
		@emails = @current_profile.emails
	end

	def preview
		@enrollment = @current_profile.enrollments.find(params[:id])
		mentee_type = @enrollment.user_type.include?('mentee')
		@user = mentee_type ? @current_profile.mentees.sample(1).first : @current_profile.mentors.sample(1).first
    add_breadcrumb "Preview"
		render 'preview'
	end

	def new
		@enrollment = @current_profile.enrollments.new
		@enrollment.steps.build
		add_breadcrumb "New Onboarding Process"
		render 'form'
	end

	def create
		merged_params = enrollment_params.merge(organization: @current_profile, author: current_user.name)
		@enrollment = Enrollment.new(merged_params)
		if @enrollment.save
			redirect_to action: 'index'
		else
			flash.now[:alert] = "Please fix the errors below."
			add_breadcrumb "New Onboarding Process"
			render 'form'
		end
	end

	def edit
		@enrollment = @current_profile.enrollments.find(params[:id])
		add_breadcrumb "Edit Onboarding Process"
		render 'form'
	end

	def update
		@enrollment = @current_profile.enrollments.find(params[:id])
		if @enrollment.update(enrollment_params.merge(updated_at: Time.now, author: current_user.name))
			redirect_to action: 'index'
		else
			flash.now[:alert] = "Please fix the errors below. #{@enrollment.errors.messages}"
			add_breadcrumb "Edit Onboarding Process"
			render 'form'
		end
	end

	def destroy
		@current_profile.enrollments.find(params[:id]).destroy
		flash.now[:success] = "Enrollment & all steps permanently deleted!"
		render 'shared/destroy.js'
  end

  def form_select
  	@step = Step.new(step_type: params[:step_type])
  	@enrollment = @current_profile.enrollments.find_by(id: params[:enrollment_id]) || Enrollment.new # needed for pre-requisite steps.
  	@index = params[:child_index].try(:to_i)
  	render 'form_select.js'
  end

  def template_fields
  	@step = Step.new(template: params[:template])
		@index = params[:child_index].try(:to_i)
  	render 'template_fields.js'
  end

  def report
  	@enrollment = @current_profile.enrollments.find(params[:id])
  	@user_ids = case @enrollment.user_type
	  	when 'mentor' then @current_profile.mentors.pluck(:id)
	  	when 'mentee' then @current_profile.mentees.pluck(:id)
	  	when 'all'	then @current_profile.users.pluck(:id)
  	end
  	add_breadcrumb "Report"
  end

private
  def enrollment_params
    params.require(:enrollment).permit(Parameters::ENROLLMENT_PARAMS)
  end
end
