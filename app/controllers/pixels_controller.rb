class PixelsController < ApplicationController
  def send_blank_gif
    # pic = Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")
    # render text: pic, type: 'image/gif'
    send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
  end

  def flush
    if request.post?
      Pixel.flush(request.remote_ip)
    end
    redirect_to root_url
  end

  def visit
    @code_or_url = params[:code_or_url]
    # get raw param string
    @code_or_url = request.original_fullpath[3..-1]
    @pixel = Pixel.where(code: @code_or_url).first
    if @pixel.nil?
      # puts request.original_fullpath[3..-1]
      # "/r/http://www.google.com"[3..-1]
      # => "http://www.google.com"
      @pixel = Pixel.where(target_url: @code_or_url).first_or_create
      @pixel.update_attribute(:code, @code_or_url) if @pixel.code.blank? 
    elsif @pixel.target_url.blank?
      @pixel.update_attribute(:target_url, @code_or_url)
    end
    # mongoid 3.1.0 style
    conditions = {:clicked => false, :request_ip => request.remote_ip, :agent => request.user_agent, :referrer => request.referrer}
    @hit = @pixel.hits.where(conditions).first
    if @hit.nil?
      @hit = @pixel.hits.create(conditions)
    end
    @hit.update_attribute(:clicked, true)
    redirect_to @pixel.target_url
    # redirect_to @code_or_url
  end

  def track
    @code = params[:code_or_url]
    @code = request.original_fullpath[3..-1]
    if !@code.blank?
      @pixel = Pixel.find_or_create_by(:code => @code)
    else
      @pixel = Pixel.find_or_create_by(:code => request.referrer)
    end
    @hit = @pixel.hits.new({:request_ip => request.remote_ip, :agent => request.user_agent, :referrer => request.referrer})
    @hit.save
    # puts @hit.as_json
    send_blank_gif
  end

  # GET /pixels
  # GET /pixels.json
  def index
    @tags = params[:tag].present? ? params[:tag] : ""
    # might want to sanitize
    if @tags.blank?
      @pixels = Pixel.all
      @tags = Pixel.tags_with_weight
    else
      @tags = @tags.split(',')
      @pixels = Pixel.tagged_with_all(@tags)
      @showgraph = true
      just_uniques = params[:unique].present? ? true : false
      today = Time.now.to_date
      pd = params[:days]
      @days = []
      if pd && !pd.blank?
        num_days = pd.to_i
        @days = ((today-num_days)..today).to_a
        oldest = @days.first
      else
        # if days are unspecified, start from the oldest
        oldest = @pixels.first.created_at
        @days = ((oldest.to_date)..today).to_a
      end
      @pixels = @pixels.where(:updated_at.gte => @days.first) if !pd.blank?
      @hits = @pixels.map{|p| p.hits.where({:created_at.gte => oldest, :created_at.lte => @days.last})}.flatten(1)
      @data_hash = Hit.hit_data(@hits, @days, just_uniques)

      @data_hash[:total_hits] = @data_hash[:hit].values.reduce(:+)
      @data_hash[:total_clicks] = @data_hash[:click].values.reduce(:+)
      @data_hash[:total_unique_hits] = @pixels.inject(0) { |sum, n|  sum + n.uniques_after(oldest).count }
      @data_hash[:total_unique_clicks] = @pixels.inject(0) { |sum, n|  sum + n.unique_clicks_after(oldest).count }
    end
    @pixels = @pixels.order_by([:created_at, :desc]) 

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pixels }
    end
  end

  # GET /pixels/1
  # GET /pixels/1.json
  def show
    @pixel = Pixel.find(params[:id])
    # @clicks = @pixel.hits.where(:clicked => true) || []
    # @uniques = @pixel.uniques
    # @unique_clicks = @clicks.distinct(:request_ip) || []
    today = Time.now.to_date
    @days = []
    pd = params[:days]
    just_uniques = params[:unique].present? ? true : false
    if pd && !pd.blank?
      num_days = pd.to_i
      @days = ((today-num_days)..today).to_a
      oldest = @days.first
      @hits = @pixel.hits.where({:created_at.gte => oldest})
    else
      # if days are unspecified, start from the oldest
      oldest = @pixel.created_at
      @days = ((oldest.to_date)..today).to_a
      @hits = @pixel.hits
    end
    @data_hash = Hit.hit_data(@hits, @days, just_uniques)

    @data_hash[:total_hits] = @data_hash[:hit].values.reduce(:+)
    @data_hash[:total_clicks] = @data_hash[:click].values.reduce(:+)
    @data_hash[:total_unique_hits] = @pixel.uniques_after(oldest).count
    @data_hash[:total_unique_clicks] = @pixel.unique_clicks_after(oldest).count

    @hits = @hits.reverse

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pixel }
    end
  end

  def geocoded
    @pixel = Pixel.find(params[:pixel_id])
    @hits = @pixel.hits
    @geo_data = @hits.map{|h| h.nice_geo_for_heatmap }

    respond_to do |format|
      format.html
      format.json { render json: @geo_data }
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
