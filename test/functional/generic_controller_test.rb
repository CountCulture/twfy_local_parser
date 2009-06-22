require 'test_helper'

# Way of testing application controller stuff (though some of this can be 
# tested in unit test) and application layout stuff
class GenericController < ApplicationController
  def index
    render :text => "index text", :layout => true
  end
  
  def show
    @council = Council.find(params[:council_id]) if params[:council_id]
    @title = "Foo Title"
    render :text => "show text", :layout => true
  end
end

class GenericControllerTest < ActionController::TestCase
  
  def setup
    ActionController::Routing::Routes.draw do |map|
      map.connect ':controller/:action/:id' # add usual route for testing purposes
    end
  end
  
  # index tests
  context "on GET to :index" do
    setup do
      get :index
    end

    should "show title" do
      assert_select "title", "They Work For You Local"
    end
  end
  
  context "on GET to :show" do
    setup do
      @council = Factory(:council)
      get :show
    end
    
    should "show given title in title" do
      assert_select "title", "Foo Title :: They Work For You Local"
    end
  end
  
  context "on GET to :show with council instantiated" do
    setup do
      @council = Factory(:council)
      get :show, :council_id => @council.id
    end
    
    should "show council in title" do
      assert_select "title", "Foo Title :: #{@council.title} :: They Work For You Local"
    end
  end
end