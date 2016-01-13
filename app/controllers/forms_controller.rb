class FormsController < ApplicationController
	add_breadcrumb "CUSTOM ONBOARDING", :organization_enrollments_path, except: [:destroy]

	def new
		@form = CustomForm.new
		@form.questions.build
		add_breadcrumb "New Application"
		render 'form'
	end

	def create
		@form = CustomForm.new(form_params.merge(organization: @current_profile, author: current_user.name))
		if @form.save
			redirect_to organization_enrollments_path(@current_profile)
		else
			flash.now[:alert] = "Please fix the errors below."
			add_breadcrumb "New Application"
			render 'form'
		end
	end

	def edit
		@form = @current_profile.forms.find(params[:id])
		add_breadcrumb "Edit Application"
		render 'form'
	end

	def update
		@form = CustomForm.find(params[:id])
		if @form.update(form_params.merge(updated_at: Time.now))
			redirect_to organization_enrollments_path(@current_profile)
		else
			flash.now[:alert] = "Please fix the errors below."
			add_breadcrumb "Edit Application"
			render 'form'
		end
	end

	def destroy
		@form = @current_profile.forms.find(params[:id])
		if @form.steps.any?
			flash.now[:alert] = "ERROR: Form belongs to step: #{@form.steps.pluck(:title).join(', ')}"
			render 'shared/errors.js'
		else
			@form.destroy
			flash.now[:success] = "Form & all responses permanently deleted!"
			render 'shared/destroy.js'
		end
  end

private
  def form_params
    params.require(:custom_form).permit(Parameters::FORM_PARAMS)
  end
end
