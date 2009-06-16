# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :share_this, :only => [:index, :show]

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '1cb17bc5dbb37dfab5a054eb922b94b3'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  private
  def authenticate
    authenticate_or_request_with_http_basic("TWFY_local") do |username, password|
      # AUTHENTICATED_USERS[username] || false
      AUTHENTICATED_USERS[username] == password
    end
  end
  
  def share_this
    @share_this = true
  end
end
