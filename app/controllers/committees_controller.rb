class CommitteesController < ApplicationController
  def show
    @committee = Committee.find(params[:id])
  end

end
