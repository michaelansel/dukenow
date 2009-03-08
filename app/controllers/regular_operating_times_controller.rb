class RegularOperatingTimesController < ApplicationController
  # GET /regular_operating_times
  # GET /regular_operating_times.xml
  def index
    @regular_operating_times = RegularOperatingTime.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @regular_operating_times }
    end
  end

  # GET /regular_operating_times/1
  # GET /regular_operating_times/1.xml
  def show
    @regular_operating_time = RegularOperatingTime.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @regular_operating_time }
    end
  end

  # GET /regular_operating_times/new
  # GET /regular_operating_times/new.xml
  def new
    @regular_operating_time = RegularOperatingTime.new
    @eateries = Eatery.find :all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @regular_operating_time }
    end
  end

  # GET /regular_operating_times/1/edit
  def edit
    @regular_operating_time = RegularOperatingTime.find(params[:id])
    @eateries = Eatery.find :all
  end

  def formHandler
    year = params[:regular_operating_time].delete('closesAt(1i)')
    month = params[:regular_operating_time].delete('closesAt(2i)')
    day = params[:regular_operating_time].delete('closesAt(3i)')
    hour = params[:regular_operating_time].delete('closesAt(4i)')
    minute = params[:regular_operating_time].delete('closesAt(5i)')
    params[:regular_operating_time][:closesAt] = Time.local( year, month, day, hour, minute )

    year = params[:regular_operating_time].delete('opensAt(1i)')
    month = params[:regular_operating_time].delete('opensAt(2i)')
    day = params[:regular_operating_time].delete('opensAt(3i)')
    hour = params[:regular_operating_time].delete('opensAt(4i)')
    minute = params[:regular_operating_time].delete('opensAt(5i)')
    params[:regular_operating_time][:opensAt] = Time.local( year, month, day, hour, minute )

    params[:regular_operating_time][:daysOfWeek] = 0
    params[:regular_operating_time]['daysOfWeekHash'].each do |dayOfWeek|
      params[:regular_operating_time][:daysOfWeek] += 1 << Date::DAYNAMES.index(dayOfWeek.capitalize)
    end
    params[:regular_operating_time].delete('daysOfWeekHash')
  end

  # POST /regular_operating_times
  # POST /regular_operating_times.xml
  def create
    formHandler

    @regular_operating_time = RegularOperatingTime.new(params[:regular_operating_time])

    respond_to do |format|
      if @regular_operating_time.save
        flash[:notice] = 'RegularOperatingTime was successfully created.'
        format.html { redirect_to(@regular_operating_time) }
        format.xml  { render :xml => @regular_operating_time, :status => :created, :location => @regular_operating_time }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @regular_operating_time.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /regular_operating_times/1
  # PUT /regular_operating_times/1.xml
  def update
    @regular_operating_time = RegularOperatingTime.find(params[:id])

    formHandler

    respond_to do |format|
      if @regular_operating_time.update_attributes(params[:regular_operating_time])
        flash[:notice] = 'RegularOperatingTime was successfully updated.'
        format.html { redirect_to(@regular_operating_time) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @regular_operating_time.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /regular_operating_times/1
  # DELETE /regular_operating_times/1.xml
  def destroy
    @regular_operating_time = RegularOperatingTime.find(params[:id])
    @regular_operating_time.destroy

    respond_to do |format|
      format.html { redirect_to(regular_operating_times_url) }
      format.xml  { head :ok }
    end
  end
end
