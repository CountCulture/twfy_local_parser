class DatasetsController < ApplicationController
  before_filter :authenticate, :except => [:index, :show, :data]

  def index
    @datasets = Dataset.find(:all)
    @title   = "All Datasets"
    respond_to do |format|
      format.html
      format.xml { render :xml => @datasets.to_xml }
      format.json { render :xml => @datasets.to_json }
    end
  end
  
  def show
    @dataset = Dataset.find(params[:id])
    @title   = @dataset.title
    respond_to do |format|
      format.html
      format.xml { render :xml => @dataset.to_xml }
      format.json { render :xml => @dataset.to_json }
    end
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
  
  # returns data for given dataset
  def data
    @dataset = Dataset.find(params[:id])
    @council = Council.find(params[:council_id])
    @data    = @dataset.data_for(@council)
    @title   = "Data for #{@dataset.title}"
  end
end
