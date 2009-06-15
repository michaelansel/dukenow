class OperatingTimesController < ApplicationController

  # GET /operating_times
  # GET /operating_times.xml
  def index
    if params[:place_id]
      @operating_times = OperatingTime.find(:all, :conditions => ['place_id = ?',params[:place_id]])
    else
      @operating_times = OperatingTime.find(:all)
    end

    request.format = :html if request.format == :iphone
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @operating_times }
    end
  end

  # GET /operating_times/1
  # GET /operating_times/1.xml
  def show
    @operating_time = OperatingTime.find(params[:id])

    request.format = :html if request.format == :iphone
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @operating_time }
    end
  end

  # GET /operating_times/new
  # GET /operating_times/new.xml
  def new
    @operating_time = OperatingTime.new
    @places = Place.find(:all, :order => "name ASC")

    request.format = :html if request.format == :iphone
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @operating_time }
    end
  end

  # GET /operating_times/1/edit
  def edit
    @operating_time = OperatingTime.find(params[:id])
    @places = Place.find(:all, :order => "name ASC")

    request.format = :html if request.format == :iphone
  end

  # POST /operating_times
  # POST /operating_times.xml
  def create
    params[:operating_time] = operatingTimesFormHandler(params[:operating_time])

    @operating_time = OperatingTime.new(params[:operating_time])

    request.format = :html if request.format == :iphone
    respond_to do |format|
      if @operating_time.save
        flash[:notice] = 'OperatingTime was successfully created.'
        format.html { redirect_to(@operating_time) }
        format.xml  { render :xml => @operating_time, :status => :created, :location => @operating_time }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @operating_time.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /operating_times/1
  # PUT /operating_times/1.xml
  def update
    @operating_time = OperatingTime.find(params[:id])

    params[:operating_time] = operatingTimesFormHandler(params[:operating_time])

    request.format = :html if request.format == :iphone
    respond_to do |format|
      if @operating_time.update_attributes(params[:operating_time])
        flash[:notice] = 'OperatingTime was successfully updated.'
        format.html { redirect_to(@operating_time) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @operating_time.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /operating_times/1
  # DELETE /operating_times/1.xml
  def destroy
    @operating_time = OperatingTime.find(params[:id])
    @operating_time.destroy

    request.format = :html if request.format == :iphone
    respond_to do |format|
      format.html { redirect_to(operating_times_url) }
      format.xml  { head :ok }
    end
  end



## Helpers ##
  def operatingTimesFormHandler(operatingTimesParams)
=begin
    params[:regular_operating_time][:opensAtOffset] =
      params[:regular_operating_time].delete('opensAtHour') * 3600 +
      params[:regular_operating_time].delete('opensAtMinute') * 60

    params[:regular_operating_time][:closesAtOffset] =
      params[:regular_operating_time].delete('closesAtHour') * 3600 +
      params[:regular_operating_time].delete('closesAtMinute') * 60
=end

    if operatingTimesParams[:daysOfWeekHash] != nil
      daysOfWeek = 0

      operatingTimesParams[:daysOfWeekHash].each do |dayOfWeek|
        daysOfWeek += 1 << Date::DAYNAMES.index(dayOfWeek.capitalize)
      end
      operatingTimesParams.delete('daysOfWeekHash')

      operatingTimesParams[:flags] = 0 if operatingTimesParams[:flags].nil?
      operatingTimesParams[:flags] = operatingTimesParams[:flags] & ~OperatingTime::ALLDAYS_FLAG
      operatingTimesParams[:flags] = operatingTimesParams[:flags] |  daysOfWeek
    end




    return operatingTimesParams
  end
end
