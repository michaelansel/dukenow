# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  before_filter :change_format_for_iphone
  after_filter :compress

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '13ac5d4b0fad8994b91b9254a0cf7661'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password


  def change_format_for_iphone
    request.format = :iphone if ApplicationHelper::iphone_user_agent?(request)
  end

  def compress
    if  self.request.env['HTTP_ACCEPT_ENCODING'] and
        self.request.env['HTTP_ACCEPT_ENCODING'].match(/gzip/) and
        self.response.headers["Content-Transfer-Encoding"] != 'binary'

      self.response.body = ActiveSupport::Gzip.compress(self.response.body)
      self.response.headers['Content-Encoding'] = 'gzip'
    end
  end

end
