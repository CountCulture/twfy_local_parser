class PortalSystemsController < ApplicationController
  before_filter :authenticate
  skip_before_filter :share_this

  def index
    @portal_systems = PortalSystem.find(:all)
  end
  
  def show
    @portal_system = PortalSystem.find(params[:id])
    @councils = @portal_system.councils
    @parsers = @portal_system.parsers
  end
  
  def new
    @portal_system = PortalSystem.new    
  end
  
  def create
    @portal_system = PortalSystem.new(params[:portal_system])
    @portal_system.save!
    flash[:notice] = "Successfully created portal system"
    redirect_to portal_system_path(@portal_system)
  rescue
    render :action => "new"
  end
  
  def edit
    @portal_system = PortalSystem.find(params[:id])
  end
  
  def update
    @portal_system = PortalSystem.find(params[:id])
    @portal_system.update_attributes!(params[:portal_system])
    flash[:notice] = "Successfully updated portal system"
    redirect_to portal_system_path(@portal_system)
  rescue
    render :action => "edit"
  end
  
end
