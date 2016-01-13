class NotesController < ApplicationController
	before_action :authenticate_partner!
	skip_before_filter :verify_authenticity_token, only: [:create]

	def new
		@note = Note.new(notable_id: params[:id], notable_type: params[:type])
		render 'form.js'
	end

	def create
		@note = Note.new(note_params.merge(staff: current_user, organization: @current_profile))
		if @note.save
			track_notes_event("new note")
      render 'save.js'
    else
    	render nothing: true
    end
	end

	def edit
		@note = @current_profile.notes.find(params[:id])
		render 'form.js'
	end

	def update
		@note = @current_profile.notes.find(params[:id])
		if @note.update(note_params)
			track_notes_event("update note")
      render 'save.js'
    else
    	render nothing: true
    end
	end

	def destroy
		@note = @current_profile.notes.find(params[:id]).destroy
		track_notes_event("delete note")
		render 'destroy.js'
	end

private
	def note_params
		params.require(:note).permit(:notable_type, :notable_id, :content)
	end

	def track_notes_event(label)
		track_event(
			label,
			id: @note.id,
			notable_id: @note.notable_id,
			notable_type: @note.notable_type,
			content: @note.content
		)
	end

end
