class TagsController < ApplicationController
	# THIS FILE IS CURRENTLY USELESS
	# aggeregate tag data
	def index

	end

	# will show a list of pixels that have a particular tag
	def show
		@tag = params[:tag]
		if @tag.present?
			@pixels = Pixel.tagged_with(@tag).order_by([:updated_at, :desc])

	    respond_to do |format|
	      format.html # index.html.erb
	      format.json { render json: @pixels }
	    end
	  else
	  	redirect_to 'tags#index'
	  end
	end
end