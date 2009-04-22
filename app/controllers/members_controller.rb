class MembersController < ApplicationController
  
  def show
    @member = Member.find(params[:id])
    @committees = @member.committees
  end
end
