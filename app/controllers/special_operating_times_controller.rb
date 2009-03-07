class SpecialOperatingTimesController < ApplicationController
  # GET /special_operating_times
  # GET /special_operating_times.xml
  def index
    @special_operating_times = SpecialOperatingTime.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @special_operating_times }
    end
  end

  # GET /special_operating_times/1
  # GET /special_operating_times/1.xml
  def show
    @special_operating_time = SpecialOperatingTime.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @special_operating_time }
    end
  end

  # GET /special_operating_times/new
  # GET /special_operating_times/new.xml
  def new
    @special_operating_time = SpecialOperatingTime.new
    @eateries = Eatery.find :all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @special_operating_time }
    end
  end

  # GET /special_operating_times/1/edit
  def edit
    @special_operating_time = SpecialOperatingTime.find(params[:id])
    @eateries = Eatery.find :all
  end

  # POST /special_operating_times
  # POST /special_operating_times.xml
  def create
    year = params[:special_operating_time].delete('closesAt(1i)')
    month = params[:special_operating_time].delete('closesAt(2i)')
    day = params[:special_operating_time].delete('closesAt(3i)')
    hour = params[:special_operating_time].delete('closesAt(4i)')
    minute = params[:special_operating_time].delete('closesAt(5i)')
    params[:special_operating_time][:closesAt] = Time.local( year, month, day, hour, minute )

    year = params[:special_operating_time].delete('opensAt(1i)')
    month = params[:special_operating_time].delete('opensAt(2i)')
    day = params[:special_operating_time].delete('opensAt(3i)')
    hour = params[:special_operating_time].delete('opensAt(4i)')
    minute = params[:special_operating_time].delete('opensAt(5i)')
    params[:special_operating_time][:opensAt] = Time.local( year, month, day, hour, minute )
    @special_operating_time = SpecialOperatingTime.new(params[:special_operating_time])

    params[:special_operating_time][:daysOfWeek] = 0
    params[:special_operating_time]['daysOfWeekHash'].each do |dayOfWeek|
      params[:special_operating_time][:daysOfWeek] += 1 << Date::DAYNAMES.index(dayOfWeek.capitalize)
    end
    params[:special_operating_time].delete('daysOfWeekHash')

    respond_to do |format|
      if @special_operating_time.save
        flash[:notice] = 'SpecialOperatingTime was successfully created.'
        format.html { redirect_to(@special_operating_time) }
        format.xml  { render :xml => @special_operating_time, :status => :created, :location => @special_operating_time }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @special_operating_time.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /special_operating_times/1
  # PUT /special_operating_times/1.xml
  def update
    year = params[:special_operating_time].delete('closesAt(1i)')
    month = params[:special_operating_time].delete('closesAt(2i)')
    day = params[:special_operating_time].delete('closesAt(3i)')
    hour = params[:special_operating_time].delete('closesAt(4i)')
    minute = params[:special_operating_time].delete('closesAt(5i)')
    params[:special_operating_time][:closesAt] = Time.local( year, month, day, hour, minute )

    year = params[:special_operating_time].delete('opensAt(1i)')
    month = params[:special_operating_time].delete('opensAt(2i)')
    day = params[:special_operating_time].delete('opensAt(3i)')
    hour = params[:special_operating_time].delete('opensAt(4i)')
    minute = params[:special_operating_time].delete('opensAt(5i)')
    params[:special_operating_time][:opensAt] = Time.local( year, month, day, hour, minute )
    @special_operating_time = SpecialOperatingTime.new(params[:special_operating_time])

    params[:special_operating_time][:daysOfWeek] = 0
    params[:special_operating_time]['daysOfWeekHash'].each do |dayOfWeek|
      params[:special_operating_time][:daysOfWeek] += 1 << Date::DAYNAMES.index(dayOfWeek.capitalize)
    end
    params[:special_operating_time].delete('daysOfWeekHash')

    respond_to do |format|
      if @special_operating_time.update_attributes(params[:special_operating_time])
        flash[:notice] = 'SpecialOperatingTime was successfully updated.'
        format.html { redirect_to(@special_operating_time) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @special_operating_time.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /special_operating_times/1
  # DELETE /special_operating_times/1.xml
  def destroy
    @special_operating_time = SpecialOperatingTime.find(params[:id])
    @special_operating_time.destroy

    respond_to do |format|
      format.html { redirect_to(special_operating_times_url) }
      format.xml  { head :ok }
    end
  end
end
