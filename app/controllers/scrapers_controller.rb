class ScrapersController < ApplicationController
  
  def index
    @scrapers = Scraper.find(:all)
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
    raise ArgumentError unless Scraper::SCRAPER_TYPES.include?(params[:type])
    @scraper = params[:type].constantize.new
    @scraper.build_parser
  end
  
  def create
    raise ArgumentError unless Scraper::SCRAPER_TYPES.include?(params[:type])
    @scraper = params[:type].constantize.create!(params[:scraper])
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
