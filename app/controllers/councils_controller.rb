class CouncilsController < ApplicationController

  def index
    @councils = Council.find(:all)
  end
  
  def show
    @council = Council.find(params[:id])
    @members = @council.members.current
  end
end
