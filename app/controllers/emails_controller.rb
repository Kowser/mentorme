class EmailsController < ApplicationController
	add_breadcrumb "CUSTOM ONBOARDING", :organization_enrollments_path, except: [:destroy]

	def preview
		@email = @current_profile.emails.find(params[:id])
		@organization = @current_profile
		add_breadcrumb "Preview"
		render 'shared_mailer/step_completed_email'
	end

	def new
		@email = CustomEmail.new
		add_breadcrumb "New Email"
		render 'form'
	end

	def create
		@email = CustomEmail.new(email_params.merge(organization: @current_profile, author: current_user.name))
		if @email.save
			redirect_to organization_enrollments_path(@current_profile)
		else
			flash.now[:alert] = fix_errors_message(@email)
			add_breadcrumb "New Email"
			render 'form'
		end
	end

	def edit
		@email = @current_profile.emails.find(params[:id])
		add_breadcrumb "Edit Email"
		render 'form'
	end

	def update
		@email = @current_profile.emails.find(params[:id])
		if @email.update(email_params.merge(author: current_user.name))
			redirect_to organization_enrollments_path(@current_profile)
		else
			flash.now[:alert] = fix_errors_message(@email)
			add_breadcrumb "Edit Email"
			render 'form'
		end
	end

	def destroy
		@email = @current_profile.emails.find(params[:id])
		if @email.steps.any?
			flash.now[:alert] = "ERROR: Email belongs to step: #{@email.steps.pluck(:title).join(', ')}"
			render 'shared/errors.js'
		else
			@email.destroy
			flash.now[:success] = "Email permanently deleted!"
			render 'shared/destroy.js'
		end
  end

private
  def email_params
    params.require(:custom_email).permit(Parameters::EMAIL_PARAMS)
  end
end