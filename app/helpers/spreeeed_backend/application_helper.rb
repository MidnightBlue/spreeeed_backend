module SpreeeedBackend
  module ApplicationHelper
    include SpreeeedBackend::MenuHelper
    include SpreeeedBackend::InputHelper
    include SpreeeedBackend::DisplayAttributeHelper


    def parent_layout(layout)
      # http://m.onkey.org/nested-layouts-in-rails-3
      @view_flow.set(:layout, output_buffer)
      self.output_buffer = render(:file => "layouts/#{layout}")
    end

    def pluralize?(name)
      !(name.pluralize == name && name.singularize == name)
    end

    def current_auth_user
      send("current_#{SpreeeedBackend.devise_auth_resource}")
    end

    def current_user_name
      if current_auth_user
        current_auth_user.respond_to?(:name) ? current_auth_user.name : current_auth_user.email
      else
        ""
      end
    end

    def current_user_is_root?
      current_auth_user.respond_to?('is_root?'.to_sym) ? current_auth_user.is_root? : true
    end

    def search_box_placeholder(klass, searchable_cols)
      res = t('search') + searchable_cols.collect do |col|
        klass.human_attribute_name(col.to_sym)
      end.join(', ')
    end


    def edit_label
      "<i class='fa fa-pencil'></i> #{t('edit')}".html_safe
    end

    def frontend_view_label
      "<i class='fa fa-eye'></i> #{t('frontend_view')}".html_safe
    end

    def destroy_label
      "<i class='fa fa-trash-o'></i> #{t('destroy')}".html_safe
    end

    def attachment_type(attachment)
      css = case attachment.content_type
              when 'image/jpeg'
                "fa-file-image-o"
              when 'application/pdf'
                "fa-file-pdf-o"
              when 'application/msword'
                "fa-file-word-o"
              else
                "fa-file-o"
            end

      %Q|<i class="fa #{css}"></i>|.html_safe
    end

  end
end
