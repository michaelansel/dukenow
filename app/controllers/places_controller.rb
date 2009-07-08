class PlacesController < ApplicationController
  ActionView::Base.send :include, TagsHelper

  before_filter :map_params, :parse_dates_and_times, :filter_xml_params, :get_at_date

  def get_at_date
    @at = params[:schedule_for_date] || Date.today
  end

  def map_params
    map  = {:from => :schedule_from, :to => :schedule_to, :on => :schedule_for_date, :at => :schedule_for_date}
    params.each{|k,v| params[map[k.to_sym]] = v if map.has_key?(k.to_sym) }
  end

  def parse_dates_and_times
    times = [:schedule_from, :schedule_to, :schedule_for_date]
    params[:schedule_from] = Time.parse(params[:schedule_from]) if params[:schedule_from]
    params[:schedule_to] = Time.parse(params[:schedule_to]) if params[:schedule_to]
    params[:schedule_for_date] = Date.parse(params[:schedule_for_date]) if params[:schedule_for_date]
  end

  def filter_xml_params
    safe = [:schedule_from, :schedule_to, :schedule_for_date]
    @xml_params ||= {}

    params.each{|k,v| @xml_params[k.to_sym] = v if safe.include?(k.to_sym) }
    RAILS_DEFAULT_LOGGER.info "XML Params: #{@xml_params.inspect}"
  end

  # GET /places
  # GET /places.xml
  def index
    @places = Place.find(:all, :order => "name ASC")
    if params[:tags]
      @selected_tags = params[:tags].split(/[,+ ][ ]*/)
    else
      @selected_tags = []
    end

    # Restrict to specific tags
    @selected_tags.each do |tag|
      RAILS_DEFAULT_LOGGER.debug "Restricting by tag: #{tag}"
      @places = @places & Place.tagged_with(tag, :on => :tags)
    end

    # Don't display machineAdded Places on the main listing
    @places = @places - Place.tagged_with("machineAdded", :on => :tags) unless @selected_tags.include?("machineAdded")


    # Calculate tag count for all Places with Tags
    #@tags = Place.tag_counts_on(:tags, :at_least => 1)

    # Manually calculate tag counts for only displayed places
    tags = []
    @places.each do |place|
      tags = tags + place.tag_list
    end

    # Remove already selected tags
    tags = tags - @selected_tags

    # Count tags and make a set of [name,count] pairs
    @tag_counts = tags.uniq.collect {|tag| [tag,tags.select{|a|a == tag}.size] }

    # Filter out single tags
    @tag_counts = @tag_counts.select{|name,count| count > 1}

    # Make the count arrays act like tags for the tag cloud
    @tag_counts.each do |a|
      a.instance_eval <<-RUBY
        def count
          self[1]
        end
        def name
          self[0]
        end
      RUBY
    end

    respond_to do |format|
      format.html # index.html.erb
      format.iphone # index.iphone.erb
      format.json { render :json => @places }
      format.xml  { render :xml => @places.to_xml(@xml_params) }
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
      format.xml  { render :xml => @place.to_xml(@xml_params) }
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
    if params[:place] and params[:place][:tag_list]
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
    if params[:place] and params[:place][:tag_list]
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
