class RegularOperatingTimesController < ApplicationController
  include RelativeTimes::ControllerMethods


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

  # POST /regular_operating_times
  # POST /regular_operating_times.xml
  def create
    params[:regular_operating_time] = operatingTimesFormHandler(params[:regular_operating_time])

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

    params[:regular_operating_time] = operatingTimesFormHandler(params[:regular_operating_time])

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
