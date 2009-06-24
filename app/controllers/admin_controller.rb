class AdminController < ApplicationController
  before_filter :authenticate

  def index
    @title = 'Admin'
  end

end
