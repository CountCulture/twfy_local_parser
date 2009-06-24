class MainController < ApplicationController
  caches_action :index
  def index
    @councils = Council.parsed.find(:all, :order => "councils.updated_at DESC", :limit => 10)
  end

end
