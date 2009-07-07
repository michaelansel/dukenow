class DiningExtension < ActiveRecord::Base
  belongs_to :place

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!(self.class.to_s.underscore.dasherize) do |xml|
      xml.tag!(:place_id.to_s.dasherize, place_id) unless options[:no_id]
      xml.tag!(:logo_url.to_s.dasherize, logo_url)
      xml.tag!(:more_info_url.to_s.dasherize, more_info_url)
      xml.tag!(:owner_operator.to_s.dasherize, owner_operator)
      xml.tag!(:payment_methods.to_s.dasherize, payment_methods)
    end
  end
end
