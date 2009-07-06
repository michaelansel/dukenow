class DiningExtension < ActiveRecord::Base
  belongs_to :place

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.dining_extension do |xml|
      xml.logo_url(logo_url)
      xml.more_info_url(more_info_url)
      xml.owner_operator(owner_operator)
      xml.payment_methods(payment_methods)
    end
  end
end
