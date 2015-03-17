module SpreeeedBackend
  module InputHelper
    extended SpreeeedBackend::BaseInputHelper

    def render_gender_input(klass, attr, form_object)
      render_radio_input(klass, attr, form_object, [I18n.t('male'), I18n.t('female')])
    end

    def render_input(klass, attr, form_object)
      klass.belongs_to_associations.each do |association|
        if "#{association}_id" == attr.to_s
          return render_association_input(klass, attr, form_object)
        end
      end


      type = klass.columns_hash[attr.to_s].type rescue :string

      case type
        when :datetime
          render_datetime_input(klass, attr, form_object)
        when :date
          render_date_input(klass, attr, form_object)
        # html_options = {}
        # case attr.to_sym
        # when :birthday
        #   html_options = {
        #     :start_year => Date.today.year - 90,
        #     :end_year   => Date.today.year - 12
        #   }
        # end
        # render_general_input(klass, attr, form_object, html_options)
        when :string
          case attr.to_sym
            when :filename
              render_image_input(klass, attr, form_object)
            when :avatar
              render_image_input(klass, attr, form_object)
            when :asset
              render_file_input(klass, attr, form_object)
            when :gender
              render_gender_input(klass, attr, form_object)

            else
              if klass.respond_to?(attr.to_s.pluralize.to_sym)
                collection = klass.send(attr.to_s.pluralize.to_sym)

                if attr.to_s == 'aasm_state'
                  mapping = collection.clone
                  collection.each do |item|
                    mapping[item] = display_state(form_object.object, attr)
                  end
                  collection = mapping
                end

                render_select_input(klass, attr, form_object, collection)
              else
                render_general_input(klass, attr, form_object)
              end
          end
        else
          render_general_input(klass, attr, form_object)
      end

    end

  end
end
