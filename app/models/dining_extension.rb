class DiningExtension < ActiveRecord::Base
  belongs_to :place

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!(self.class.to_s.pluralize.underscore.dasherize) do |xml|
      attrs = self.attributes()

      # Remove attributes we don't want to include
      attrs.delete(:id.to_s)
      attrs.delete(:created_at.to_s)
      attrs.delete(:updated_at.to_s)

      attrs.delete(:place_id.to_s) if options[:no_id]

      # Build dining-extensions tag
      attrs.each do |attr,val|
        xml.tag!(attr.to_s.dasherize, {:label => attr.titleize}, val)
      end
    end
  end
end
