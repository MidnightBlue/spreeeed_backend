module SpreeeedBackend
  module DisplayAttributeHelper

    def display_attribute(object, attr)
      if association = detect_association(object, attr)
        return object.send(association.to_sym).name
      end

      object.send(attr.to_sym)
    end


    def detect_association(object, attr)
      if attr.to_s.include?('_id') and association = attr.to_s.gsub('_id', '')
        if object.class.belongs_to_associations.include?(association.to_sym)
          return association
        end
      end
      false
    end

    def format_value(value)
      # Rails.logger.debug(value.class)
      case value.class.to_s
        when 'ActiveSupport::TimeWithZone'
          value.strftime("%Y/%m/%d %H:%M")
        when 'TrueClass'
          yes_or_no(value)
        when 'String'
          simple_format(value)
        else
          value
      end
    end

    def display_value(object, attr)
      value = object.send(attr.to_sym)
      content_tag :td, :class => 'text-right' do
        value
      end.html_safe
    end

    def yes_or_no(flag)
      if flag
        %Q|<i class="fa fa-check" style="color: #19B698;"></i>|.html_safe
      else
        %Q|<i class="fa fa-times" style="color: #EA6153;"></i>|.html_safe
      end
    end

    def object_image_tag(object, html_options={})
      size = html_options.delete(:size)
      url = size ? object.filename.url(size) : object.filename.url

      image_tag(url, html_options) rescue ''
    end

    def object_photo(object, html_options={})
      if object.respond_to?(:photo) and object.photo.present?
        object_image_tag(object.photo, html_options)
      elsif object.respond_to?(:avatar) and object.avatar.present?
        object_image_tag(object.avatar, html_options)
      elsif object.respond_to?(:photos) and object.photos.count > 0
        Rails.logger.info("==== #{object.class} #{object.id}")
        object_image_tag(object.photos.first, html_options)
      end
    end

    def object_name(object)
      if object.respond_to?(:name)
        object.name
      elsif object.respond_to?(:title)
        object.title
      else
        object.id
      end
    end

  end
end
