class CheckInsController < ApplicationController
  before_action :authenticate_mentor!, only: [:new, :create]
  before_action :crumbs, except: [:attendees]

  def index
    @match_names = @current_profile.matches.where(id: @current_profile.check_ins.pluck(:match_id).uniq).map(&:name).sort
    @search = params[:search] ? Search.new(search_params) : Search.new
    @check_ins = Search.check_ins(@current_profile, params[:search]).paginate(page: params[:page], per_page: 25)
  end

  def new
    @check_in = CheckIn.new
    @match = current_user.matches.first
    @rating = current_user.ratings.build
    add_breadcrumb "New Check-In"
    render 'form'
  end

  def create
    @matches = current_user.matches # for drop down if re-rendering form
    @match = @matches.find(check_in_params[:match_id])
    @check_in = CheckIn.new(check_in_params)
    last_check_in = @match.check_ins.find_by(date: check_in_params[:date])
    add_breadcrumb "New Check-In"

    if !check_in_params[:mentor_ids].include?(current_user.id.to_s)
      flash.now[:alert] = "You must be present to Check-In."
      render 'form'
    elsif last_check_in && params[:override] != 'true'
      flash.now[:alert] = "This match has a <a href='#{edit_user_check_in_path(current_user, last_check_in)}'>
        Check-In</a> for that date. If you wish to create this Check-In anyway, please submit again.".html_safe
      params[:override] = true
      render 'form'
    elsif @check_in.save
      @rating = @check_in.ratings.first
      track_check_in_event("new check-in")
      flash[:success] = 'Check-In Saved!'
      redirect_to user_check_ins_path
    else
      flash.now[:alert] = fix_errors_message(@check_in)
      render 'form'
    end

    rescue
      @check_in.errors.add(:date, 'Format must be m/d/y')
      flash.now[:alert] = fix_errors_message(@check_in)
      add_breadcrumb "New Check-In"
      render 'form'
  end

  def show
    @check_in = @current_profile.check_ins.find(params[:id])
    add_breadcrumb "View"
  end

  def edit
    @check_in = current_user.check_ins.find(params[:id])
    @match = @check_in.match
    @rating = current_user.ratings.where(check_in: @check_in).first_or_initialize
    add_breadcrumb "Edit"
    render 'form'
  end

  def update
    @check_in = current_user.check_ins.find(params[:id])
    @rating = current_user.ratings.build(check_in_params[:ratings_attributes]['0'].merge(check_in: @check_in))

    if @check_in.update(check_in_params)
      track_check_in_event("update check-in")
      flash[:success] = "Check-In updated!"
      redirect_to user_check_ins_path
    else
      @match = @check_in.match
      @rating.valid?
      flash.now[:alert] = fix_errors_message(@check_in)
      render 'form'
    end
  end

  def attendees
    @match = @current_profile.matches.find(params[:id])
    render 'attendees.js'
  end

protected
  def crumbs
    add_breadcrumb "CHECK-INS", current_user.is_partner? ? organization_check_ins_path : user_check_ins_path
  end

private
  def check_in_params
    params.require(:check_in).permit(Parameters::CHECK_IN_PARAMS)
  end

  def track_check_in_event(label)
    track_event(
      label,
      id: @check_in.id,
      role: current_user.role,
      length: @check_in.length.to_f,
      location: @check_in.location,
      meeting_type: @check_in.meeting_type,
      match_id: @check_in.match_id,
      date: @check_in.date,
      next_date: @check_in.next_date,
      rating: @rating.rating.to_i,
      notes: @rating.notes
    )
  end
end
