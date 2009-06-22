class CouncilsController < ApplicationController
  before_filter :authenticate, :except => [:index, :show]

  def index
    @councils = params[:include_unparsed] ? Council.find(:all, :order => "name") : Council.parsed
    @title = "All Councils"
    respond_to do |format|
      format.html
      format.xml { render :xml => @councils.to_xml }
      format.json { render :json =>  @councils.to_json }
    end
  end
  
  def show
    @council = Council.find(params[:id])
    @members = @council.members.current
    respond_to do |format|
      format.html
      format.xml { render :xml => @council.to_xml }
      format.json { render :json =>  @council.to_json }
    end
  end
  
  def new
    @council = Council.new
  end
  
  def create
    @council = Council.new(params[:council])
    @council.save!
    flash[:notice] = "Successfully created council"
    redirect_to council_path(@council)
  rescue
    render :action => "new"
  end
  
  def edit
    @council = Council.find(params[:id])
  end
  
  def update
    @council = Council.find(params[:id])
    @council.update_attributes!(params[:council])
    flash[:notice] = "Successfully updated council"
    redirect_to council_path(@council)
  rescue
    render :action => "edit"
  end
end
