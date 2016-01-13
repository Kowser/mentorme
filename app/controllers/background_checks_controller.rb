class BackgroundChecksController < ApplicationController
  add_breadcrumb "BACKGROUND CHECKS", :organization_background_checks_path, except: [:api_checkr]

  def index
    @search = params[:search] ? Search.new(search_params) : Search.new
    @background_checks = Search.background_checks(@current_profile, params[:search]).paginate(page: params[:page], per_page: 25)
  end

  def api_checkr
    bg_params = params['data']['object']
    if @background_check = BackgroundCheck.find_by(checkr: bg_params['candidate_id'])
      @background_check.update(status: bg_params['status'].try(:capitalize))
    else
      message = "Background Check API error.<br><br>#{payload}."
      (BackgroundCheck.new).notify_dev(message)
    end

    render nothing: true
  end

  def new #only for partner staff
    @user = @current_profile.users.find_by(id: background_params[:user_id]) if params[:background_check]
    add_breadcrumb "New Background Check"
    render "enrollments/template_forms/background"
  end

  def create
    @background_check = BackgroundCheck.where(user_id: background_params[:user_id]).first_or_initialize(background_params)
    @user ||= @background_check.user

  	if @background_check.valid?
  	  checkr_params = background_params.delete_if { |k, v| v.blank? }.merge(custom_id: @user.id.to_s)
  	  candidate_request = Net::HTTP.post_form(URI.parse("https://#{ENV['CHECKR_API_KEY']}:@api.checkr.io/v1/candidates/"), checkr_params)
  	  candidate = JSON.parse(candidate_request.body)

      if candidate['error'] # fix candidate submission
        @background_check.errors.add(:base, candidate['error']) # if current_user.is_partner?
        add_breadcrumb "New Background Check"
        resubmit_form
      else # submit a candidate report request
        @background_check.checkr = candidate['id']
        report_params = {}
        report_params[:package] = 'driver_plus'
        report_params[:candidate_id] = candidate['id']
        report_request = Net::HTTP.post_form(URI.parse("https://#{ENV['CHECKR_API_KEY']}:@api.checkr.com/v1/reports"), report_params)

        # TESTING MODE CURRENTLY
        # report_params[:candidate_id] = 'e44aa283528e6fde7d542194'
        # report_request = Net::HTTP.post_form(URI.parse("https://83ebeabdec09f6670863766f792ead24d61fe3f9:@api.checkr.com/v1/reports"), report_params)
        # END TESTING MODE
        report = JSON.parse(report_request.body)

        if report['error'] # saves candidate with a status of 'Error' & emails dev team about it
          @background_check.status = 'Error'
          @background_check.error_msg = report['error']
        else # successful report submission
          @background_check.status = report['status'].try(:capitalize)
        end
        @background_check.update(background_params)
        @user.update_status(@step) if @step = @user.steps.find_by(id: params[:step_id])
        flash[:success] = @step.try(:notification).try(:present?) ? @step.notification : 'Background Submitted! Thank you!'
        redirect_to current_user.is_partner? ? organization_background_checks_path(@current_profile) : current_user
      end
    else
      add_breadcrumb "New Background Check"
      resubmit_form
    end
  end

private
  def resubmit_form
    flash.now[:alert] = alert_message(@background_check)
    @step = @user.steps.find_by(id: params[:step_id])
    render "enrollments/template_forms/background"
  end

	def background_params
	  params.require(:background_check).permit(Parameters::BACKGROUND_PARAMS)
	end

  def test_params
    params = '{
      "id": "507f1f77bcf86cd799439011",
      "object": "event",
      "type": "report.completed",
      "created_at": "2014-01-18T12:34:00Z",
      "webhook_url": "https://yourcompany.com/checkr/incoming",
      "data": {
        "object": {
          "id": "4722c07dd9a10c3985ae432a",
          "object": "report",
          "uri": "/v1/reports/532e71cfe88a1d4e8d00000d",
          "created_at": "2014-01-18T12:34:00Z",
          "received_at": "2014-01-18T12:34:00Z",
          "status": "clear",
          "package": "driver_plus",
          "candidate_id": "e44aa283528e6fde7d542194",
          "ssn_trace_id": "539fd88c101897f7cd000001",
          "sex_offender_search_id": "539fd88c101897f7cd000008",
          "national_criminal_search_id": "539fd88c101897f7cd000006",
          "county_criminal_search_ids": [
            "539fdcf335644a0ef4000001",
            "532e71cfe88a1d4e8d00000i"
          ],
          "motor_vehicle_report_id": "539fd88c101897f7cd000007"
        }
      }
    }'
  end

end
