class ScrapersController < ApplicationController
  
  def index
    @councils = Council.find(:all, :include => :scrapers, :order => "name")
  end
  
  def show
    @scraper = Scraper.find(params[:id])
    if params[:dry_run]
      @results = @scraper.process.results
    elsif params[:process]
      @results = @scraper.process(:save_results => true).results
    end
    @parser = @scraper.parser
  end
  
  def new
    raise ArgumentError unless Scraper::SCRAPER_TYPES.include?(params[:type]) && params[:council_id]
    @scraper = params[:type].constantize.new(:council_id => params[:council_id])
    @scraper.build_parser(:result_model => params[:result_model])
  end
  
  def create
    raise ArgumentError unless Scraper::SCRAPER_TYPES.include?(params[:type])
    @scraper = params[:type].constantize.new(params[:scraper])
    @scraper.save!
    flash[:notice] = "Successfully created scraper"
    redirect_to scraper_url(@scraper)
  end
  
  def edit
    @scraper = Scraper.find(params[:id])
  end
  
  def update
    @scraper = Scraper.find(params[:id])
    @scraper.update_attributes!(params[:scraper])
    flash[:notice] = "Successfully updated scraper"
    redirect_to scraper_url(@scraper)
  end
end
