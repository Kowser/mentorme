class AttachmentsController < ApplicationController
	before_action :authenticate_user!, only: [:destroy]
	
  def destroy
    Attachment.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { render nothing: true }
    end
  end
end
