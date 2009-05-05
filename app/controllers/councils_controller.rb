class CouncilsController < ApplicationController

  def index
    @councils = Council.find(:all)
  end
  
  def show
    @council = Council.find(params[:id])
    @members = @council.members.current
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
    logger.debug { "message" }
    render :action => "edit"
  end
end
