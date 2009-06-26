class DatasetsController < ApplicationController
  before_filter :authenticate
  skip_before_filter :share_this

  def index
    @datasets = Dataset.find(:all)
  end
  
  def show
    @dataset = Dataset.find(params[:id])
    @title = @dataset.title
  end
  
  def new
    @dataset = Dataset.new    
  end
  
  def create
    @dataset = Dataset.new(params[:dataset])
    @dataset.save!
    flash[:notice] = "Successfully created dataset"
    redirect_to dataset_path(@dataset)
  rescue
    render :action => "new"
  end
  
  def edit
    @dataset = Dataset.find(params[:id])
  end
  
  def update
    @dataset = Dataset.find(params[:id])
    @dataset.update_attributes!(params[:dataset])
    flash[:notice] = "Successfully updated dataset"
    redirect_to dataset_url(@dataset)
  rescue
    render :action => "edit"
  end
end
