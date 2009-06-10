class MeetingsController < ApplicationController
  
  def show
    @meeting = Meeting.find(params[:id])
    @committee = @meeting.committee
    @other_meetings = @committee.meetings - [@meeting]
    @title = @meeting.title
    respond_to do |format|
      format.html
      format.xml { render :xml => @meeting.to_xml }
      format.json { render :json => @meeting.to_json }
    end
  end
end
