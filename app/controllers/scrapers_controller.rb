class ScrapersController < ApplicationController
  
  def index
    @scrapers = Scraper.find(:all)
  end
  
  def show
    @scraper = Scraper.find(params[:id])
    if params[:dry_run]
      @results = @scraper.test.results
    elsif params[:process]
      @results = @scraper.update_from_url.results
    end
    @parser = @scraper.parser
  end
  
  def new
    @scraper = Scraper.new
    @scraper.build_parser
  end
  
  def create
    @scraper = Scraper.create!(params[:scraper])
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
