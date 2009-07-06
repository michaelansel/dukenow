class DiningExtensionsController < ApplicationController
  # GET /dining_extensions
  # GET /dining_extensions.xml
  def index
    @dining_extensions = DiningExtension.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dining_extensions }
    end
  end

  # GET /dining_extensions/1
  # GET /dining_extensions/1.xml
  def show
    @dining_extension = DiningExtension.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dining_extension }
    end
  end

  # GET /dining_extensions/new
  # GET /dining_extensions/new.xml
  def new
    @dining_extension = DiningExtension.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dining_extension }
    end
  end

  # GET /dining_extensions/1/edit
  def edit
    @dining_extension = DiningExtension.find(params[:id])
  end

  # POST /dining_extensions
  # POST /dining_extensions.xml
  def create
    @dining_extension = DiningExtension.new(params[:dining_extension])

    respond_to do |format|
      if @dining_extension.save
        flash[:notice] = 'DiningExtension was successfully created.'
        format.html { redirect_to(@dining_extension) }
        format.xml  { render :xml => @dining_extension, :status => :created, :location => @dining_extension }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dining_extension.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dining_extensions/1
  # PUT /dining_extensions/1.xml
  def update
    @dining_extension = DiningExtension.find(params[:id])

    respond_to do |format|
      if @dining_extension.update_attributes(params[:dining_extension])
        flash[:notice] = 'DiningExtension was successfully updated.'
        format.html { redirect_to(@dining_extension) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dining_extension.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dining_extensions/1
  # DELETE /dining_extensions/1.xml
  def destroy
    @dining_extension = DiningExtension.find(params[:id])
    @dining_extension.destroy

    respond_to do |format|
      format.html { redirect_to(dining_extensions_url) }
      format.xml  { head :ok }
    end
  end
end
