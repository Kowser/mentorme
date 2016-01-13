class OrganizationsUsersController < ApplicationController
	before_action :authenticate_partner!

	def update
		@organizations_user = OrganizationsUser.find(params[:id])
		if @organizations_user.update(organizations_user_params)
			flash[:success] = "File Uploaded"
	  else
	  	flash[:alert] = fix_errors_message(@organizations_user)
	  end
	  redirect_to :back
	end
  
private
	def organizations_user_params
		params.require(:organizations_user).permit(Parameters::ORGANIZATIONS_USERS_PARAMS)
	end
end
