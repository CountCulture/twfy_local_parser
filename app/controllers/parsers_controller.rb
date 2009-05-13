class ParsersController < ApplicationController

  def show
    @parser = Parser.find(params[:id])
  end
  
  def new
    raise ArgumentError unless params[:portal_system_id]
    @parser = PortalSystem.find(params[:portal_system_id]).parsers.build
  end
  
  def edit
    @parser = Parser.find(params[:id])
  end
  
  def create
    @parser = Parser.new(params[:parser])
    @parser.save!
    flash[:notice] = "Successfully created parser"
    redirect_to parser_path(@parser)
  rescue
    render :action => "new"
  end
  
  def update
    @parser = Parser.find(params[:id])
    @parser.update_attributes!(params[:parser])
    flash[:notice] = "Successfully updated parser"
    redirect_to parser_path(@parser)
  rescue
    render :action => "edit"
  end
  
end
