class SpecialOperatingTimesController < ApplicationController
  include RelativeTimes::ControllerMethods

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
    operatingTimesFormHandler
    @special_operating_time = SpecialOperatingTime.new(params[:special_operating_time])

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
    @special_operating_time = SpecialOperatingTime.find(params[:id])
    operatingTimesFormHandler

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
