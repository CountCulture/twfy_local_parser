class DocumentsController < ApplicationController
  def show
    @document = Document.find(params[:id])
    @title = "Meeting Minutes"
  end

end
