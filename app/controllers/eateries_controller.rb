class EateriesController < ApplicationController
  # GET /eateries
  # GET /eateries.xml
  def index
    @eateries = Eatery.find(:all)
    # Merchants On Points
    # West Campus
    # East Campus

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @eateries }
    end
  end

  # GET /eateries/1
  # GET /eateries/1.xml
  def show
    @eatery = Eatery.find(params[:id])
    @schedule = @eatery.schedule

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @eatery }
    end
  end

  # GET /eateries/new
  # GET /eateries/new.xml
  def new
    @eatery = Eatery.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @eatery }
    end
  end

  # GET /eateries/1/edit
  def edit
    @eatery = Eatery.find(params[:id])
  end

  # POST /eateries
  # POST /eateries.xml
  def create
    @eatery = Eatery.new(params[:eatery])

    respond_to do |format|
      if @eatery.save
        flash[:notice] = 'Eatery was successfully created.'
        format.html { redirect_to(@eatery) }
        format.xml  { render :xml => @eatery, :status => :created, :location => @eatery }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @eatery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /eateries/1
  # PUT /eateries/1.xml
  def update
    @eatery = Eatery.find(params[:id])

    respond_to do |format|
      if @eatery.update_attributes(params[:eatery])
        flash[:notice] = 'Eatery was successfully updated.'
        format.html { redirect_to(@eatery) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @eatery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /eateries/1
  # DELETE /eateries/1.xml
  def destroy
    @eatery = Eatery.find(params[:id])
    @eatery.destroy

    respond_to do |format|
      format.html { redirect_to(eateries_url) }
      format.xml  { head :ok }
    end
  end

  # GET /eateries/open
  # GET /eateries/open.xml
  def open
    @eatery = Eatery.find(params[:id])

    respond_to do |format|
      format.html # open.html.erb
      format.xml  { render :xml => @eatery }
    end
  end
end
