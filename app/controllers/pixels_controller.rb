class PixelsController < ApplicationController

  def send_blank_gif
    # pic = Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
    # render text: pic, type: 'image/gif'
    send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
  end

  def track
    @code = params[:code]
    @pixel = Pixel.find_or_create_by(:code => @code)
    @hit = @pixel.hits.new({:request_ip => request.remote_ip, :agent => request.env["HTTP_USER_AGENT"], :referrer => request.env["HTTP_REFERER"]})
    @hit.save
    # puts @hit.as_json
    send_blank_gif
  end

  # GET /pixels
  # GET /pixels.json
  def index
    @pixels = Pixel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pixels }
    end
  end

  # GET /pixels/1
  # GET /pixels/1.json
  def show
    @pixel = Pixel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pixel }
    end
  end

  # GET /pixels/new
  # GET /pixels/new.json
  def new
    @pixel = Pixel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pixel }
    end
  end

  # GET /pixels/1/edit
  def edit
    @pixel = Pixel.find(params[:id])
  end

  # POST /pixels
  # POST /pixels.json
  def create
    @pixel = Pixel.new(params[:pixel])

    respond_to do |format|
      if @pixel.save
        format.html { redirect_to @pixel, notice: 'Pixel was successfully created.' }
        format.json { render json: @pixel, status: :created, location: @pixel }
      else
        format.html { render action: "new" }
        format.json { render json: @pixel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pixels/1
  # PUT /pixels/1.json
  def update
    @pixel = Pixel.find(params[:id])

    respond_to do |format|
      if @pixel.update_attributes(params[:pixel])
        format.html { redirect_to @pixel, notice: 'Pixel was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pixel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pixels/1
  # DELETE /pixels/1.json
  def destroy
    @pixel = Pixel.find(params[:id])
    @pixel.destroy

    respond_to do |format|
      format.html { redirect_to pixels_url }
      format.json { head :no_content }
    end
  end
end
