class RegistrationsController < Devise::RegistrationsController
	before_action :crumbs, only: [:edit, :update]

  def create
    super
    if resource.persisted?
      track_event("user registered", role: resource.role)
    end
  end

protected
	def crumbs
		add_breadcrumb 'PROFILE', user_path(current_user)
		add_breadcrumb 'Edit Name & Login'
	end

  def after_update_path_for(user)
    after_sign_in_path_for(user)
  end
end
