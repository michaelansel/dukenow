class PlacesController < ApplicationController
  ActionView::Base.send :include, TagsHelper

  before_filter :get_at_date

  def get_at_date
    params[:at] = Date.today.to_s if params[:at].nil?
    @at = Date.parse(params[:at])
  end

  # GET /places
  # GET /places.xml
  def index
    @places = Place.find(:all, :order => "name ASC")

    # Restrict to specific tags
    if params[:tags]

      params[:tags].split(/[,+ ][ ]*/).each do |tag|
        RAILS_DEFAULT_LOGGER.debug "Restricting by tag: #{tag}"
        @places = @places & Place.tagged_with(tag, :on => :tags)
      end

    else
      @places = @places - Place.tagged_with("machineAdded", :on => :tags)

    end

    @tags = Place.tag_counts_on(:tags)

    respond_to do |format|
      format.html # index.html.erb
      format.iphone { render :layout => "places.html.erb" } # index.iphone.erb
      format.xml  { render :xml => @places }
    end
  end

  def tag
    redirect_to :action => :index, :tags => params.delete(:id)
  end

  # GET /places/1
  # GET /places/1.xml
  def show
    @place = Place.find(params[:id])

    request.format = :html if request.format == :iphone
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/new
  # GET /places/new.xml
  def new
    @place = Place.new

    request.format = :html if request.format == :iphone
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/1/edit
  def edit
    @place = Place.find(params[:id])

    request.format = :html if request.format == :iphone
  end

  # POST /places
  # POST /places.xml
  def create
    if params[:place][:tag_list]
      params[:place][:tag_list].strip!
      params[:place][:tag_list].gsub!(/( )+/,', ')
    end
    @place = Place.new(params[:place])

    request.format = :html if request.format == :iphone
    respond_to do |format|
      if @place.save
        flash[:notice] = 'Place was successfully created.'
        format.html { redirect_to(@place) }
        format.xml  { render :xml => @place, :status => :created, :location => @place }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /places/1
  # PUT /places/1.xml
  def update
    @place = Place.find(params[:id])
    if params[:place][:tag_list]
      params[:place][:tag_list].strip!
      params[:place][:tag_list].gsub!(/( )+/,', ')
    end

    request.format = :html if request.format == :iphone
    respond_to do |format|
      if @place.update_attributes(params[:place])
        flash[:notice] = 'Place was successfully updated.'
        format.html { redirect_to(@place) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.xml
  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    request.format = :html if request.format == :iphone
    respond_to do |format|
      format.html { redirect_to(places_url) }
      format.xml  { head :ok }
    end
  end

  # GET /places/open
  # GET /places/open.xml
  def open
    @place = Place.find(params[:id])

    request.format = :html if request.format == :iphone
    respond_to do |format|
      format.html # open.html.erb
      format.xml  { render :xml => @place }
    end
  end
end
