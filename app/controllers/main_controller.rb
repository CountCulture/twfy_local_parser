class MainController < ApplicationController
  def index
    @councils = Council.parsed.find(:all, :order => "updated_at DESC", :limit => 10)
  end

end
