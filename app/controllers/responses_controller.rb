class ResponsesController < ApplicationController
	before_action :find_user, except: [:preview]
	before_action :crumbs

	def preview
		@response = CustomFormResponse.new(form_id: params[:id])
		@object = [@current_profile, @response]
		@preview = true
		add_breadcrumb "CUSTOM ONBOARDING", :organization_enrollments_path
		add_breadcrumb "Application Preview"
		render 'form'
	end

	def new
		@response = @user.responses.where(form_id: params[:form_id]).first_or_initialize
		@step = @user.steps.find_by(id: params[:step_id])
		@object = current_user.is_partner? ? [@current_profile, @user, @response] : [current_user, @response]
		add_breadcrumb "#{@response.form.organization.name} > #{@response.form.title}"
		render 'form'
	end

	def create
		@response = @user.responses.new(response_params)
		@step = @user.steps.find(params[:step_id])

		if @response.save
			@user.update_status(@step)
			flash[:success] = @step.notification.present? ? @step.notification : 'Saved! Thank you!'
			track_response_event("user completed step")
			redirect_to current_user.is_partner? ? organization_user_path(@current_profile, @user) : current_user
		else
			@object = current_user.is_partner? ? [@current_profile, @user, @response] : [current_user, @response]
			flash.now[:alert] = alert_message(@response)
			add_breadcrumb "#{@response.form.organization.name} > #{@response.form.title}"
			render 'form'
		end
	end

	def edit
		@response = @user.responses.find(params[:id])
		@object = current_user.is_partner? ? [@current_profile, @user, @response] : [current_user, @response]
		add_breadcrumb "#{@response.form.organization.name} > #{@response.form.title}"
		render 'form'
	end

	def update
		# NOTICE: There is no step (status) completion. If an existing form is attached to a new step, the user
		# will be unable to complete the step and will be stuck in a loop.
		@response = @user.responses.find(params[:id])
		if @response.update(response_params)
			flash[:success] = 'Updates saved: Thank you!'
			track_response_event("user upated response")
			redirect_to current_user.is_partner? ? organization_user_path(@current_profile, @user) : current_user
		else
			@object = current_user.is_partner? ? [@current_profile, @user, @response] : [current_user, @response]
			flash[:alert] = alert_message(@response)
			add_breadcrumb "#{@response.form.organization.name} > #{@response.form.title}"
			render 'form'
		end
	end

protected
	def crumbs
		if current_user.is_partner?
			add_breadcrumb "#{@user.role.try(:upcase)}S", organization_users_path(search: {role: @user.role})
			add_breadcrumb "#{@user.name}", organization_user_path(@current_profile, @user)
		else
			add_breadcrumb 'PROFILE', user_path(current_user)
		end
	end

private
	def response_params
		params.require(:custom_form_response).permit!
	end



	def track_response_event(label)
		track_event(
			label,
			response_id: @response.id,
			step_id: @step.try(:id),
			user_id: current_user.id,
			role: current_user.role,
			template: @step.try(:template)
		)
	end
end
