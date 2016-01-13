class ReferencesController < ApplicationController
  layout 'landing', only: [:edit, :update, :confirmation]
  before_action :authenticate_partner!, only: [:index, :show]
  before_action :authenticate_user!, except: [:edit, :update, :confirmation]
  add_breadcrumb "REFERENCES", :organization_references_path, only: [:index, :show]

  def index
    @search = params[:search] ? Search.new(search_params) : Search.new
    @references = Search.references(@current_profile, params[:search]).paginate(page: params[:page], per_page: 25)
  end

  def show
    unless @reference = @current_profile.references.find_by(id: params[:id])
      flash[:alert] = 'Invalid Reference'
      redirect_to @current_profile
    end
    @user = @reference.user
    add_breadcrumb "#{@reference.name}"
  end

  def edit
    @reference = Reference.find_by(url_token: params[:token]) if params[:token]
    if !@reference
      flash[:alert] = 'Please use the link provided in your email.'
      redirect_to root_path
    elsif @reference.completed
      flash[:alert] = 'You have already written an endorsement. Thank you!'
      redirect_to root_path
    else
      # shortened variable name used in form
      @user_name = @reference.user.name
    end
  end

  def update
    @reference = Reference.find(params[:id])
    respond_to do |format|
      format.html {
        if @reference.update(reference_params)
          flash.now[:success] = 'Endorsement Saved!'
          render 'confirmation'
        else
          @user_name = @reference.user.name
          flash.now[:alert] = "Please fix the errors below"
          render 'edit'
        end
      }
      
      format.js {
        @reference.update(reference_params)
        render nothing: true
      }
    end    
  end

  def resend_notification
    @reference = Reference.find(params[:id])
    @reference.notify_reference
    flash[:success] = "Notification resent to #{@reference.name}"
    redirect_to :back
  end

  def confirmation
  end

private
  def reference_params
    params.require(:reference).permit(Parameters::REFERENCE_PARAMS)
  end

end
