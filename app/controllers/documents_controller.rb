class DocumentsController < ApplicationController
  def show
    @document = Document.find(params[:id])
    @council = @document.document_owner.council
    @title = @document.title
  end

end
