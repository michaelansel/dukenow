class OperatingTimesController < ApplicationController
  include RelativeTimes::ControllerMethods

  # GET /operating_times
  # GET /operating_times.xml
  def index
    @operating_times = OperatingTime.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @operating_times }
    end
  end

  # GET /operating_times/1
  # GET /operating_times/1.xml
  def show
    @operating_time = OperatingTime.find(params[:id])
    @places = Place.find(:all)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @operating_time }
    end
  end

  # GET /operating_times/new
  # GET /operating_times/new.xml
  def new
    @operating_time = OperatingTime.new
    @places = Place.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @operating_time }
    end
  end

  # GET /operating_times/1/edit
  def edit
    @operating_time = OperatingTime.find(params[:id])
    @places = Place.find(:all)
  end

  # POST /operating_times
  # POST /operating_times.xml
  def create
    params[:operating_time] = operatingTimesFormHandler(params[:operating_time])

    @operating_time = OperatingTime.new(params[:operating_time])

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

    respond_to do |format|
      format.html { redirect_to(operating_times_url) }
      format.xml  { head :ok }
    end
  end
end
