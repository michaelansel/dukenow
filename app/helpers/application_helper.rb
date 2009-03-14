# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Request from an iPhone or iPod touch? (Mobile Safari user agent)
  def iphone_user_agent?(request = self.request)
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end
  module_function :iphone_user_agent?

end
