module SpreeeedBackend
  module BaseInputHelper

    def bind_validators(klass, attr, html_options={:class => 'form-control'})
      validators = klass.validators_on(attr.to_sym)
      return html_options if validators.empty?

      html_options[:class] += ' parsley-validated'
      validators.each do |validator|
        case validator.class.name
          when 'ActiveModel::Validations::PresenceValidator'
            html_options[:required] = 'required'
        end
      end

      return html_options
    end

    def render_hidden_input(klass, attr, form_object, html_options={})
      form_object.hidden_field attr.to_sym, {:value => form_object.object.send(attr.to_sym)}
    end

    def render_general_input(klass, attr, form_object, html_options={})
      name = [klass.name.underscore, attr].join('_')

      content_tag :div, :class => "form-group" do
        content = content_tag :label, :class => "col-sm-3 control-label", :for => name do
          klass.human_attribute_name(attr.to_sym)
        end

        content += content_tag :div, :class => "col-sm-7" do
          sub_content = content_tag :div, :class => "input-group" do
            form_object.input_field attr.to_sym, bind_validators(klass, attr).merge(html_options)
          end
          sub_content += content_tag :div, :id => "#{name}-error" do
          end

          sub_content
        end

        content
      end
    end

    def render_radio_input(klass, attr, form_object, collection)
      id = [klass.name.underscore, attr].join('_')

      content_tag :div, :class => "form-group" do
        c1 = content_tag :label, :class => "col-sm-3 control-label", :for => id do
          klass.human_attribute_name(attr.to_sym)
        end

        c1 += content_tag :div, :class => "col-sm-6" do
          collection.collect do |item|
            content_tag :label, :class => 'radio-inline' do
              html_options = {:class => 'icheck', :type => 'radio', :value => item, :style => "position: absolute; opacity: 0;"}
              if form_object.object.send(attr.to_sym) == item
                html_options.merge!({:checked => 'checked'})
              end
              html_options = bind_validators(klass, attr).merge(html_options)
              form_object.input_field(attr.to_sym, html_options) + ' ' + item
            end
          end.join(' ').html_safe
        end

        c1
      end
    end

    def render_select_input(klass, attr, form_object, collection)
      id = [klass.name.underscore, attr].join('_')

      content_tag :div, :class => "form-group" do
        c1 = content_tag :label, :class => "col-sm-3 control-label", :for => id do
          klass.human_attribute_name(attr.to_sym)
        end

        c1 += content_tag :div, :class => "col-sm-6" do
          content_tag :div, :class => "input-group" do
            html_options = bind_validators(klass, attr).merge({:collection => collection})
            form_object.input_field(attr.to_sym, html_options)
          end
        end

        c1
      end
    end

    def render_tags_input(klass, attr, form_object, tags=0)
      id = [klass.name.underscore, attr].join('_')

      content_tag :div, :class => "form-group" do
        c1 = content_tag :label, :class => "col-sm-3 control-label", :for => id do
          klass.human_attribute_name(attr.to_sym)
        end

        c1 += content_tag :div, :class => "col-sm-6" do
          content_tag :div, :class => "input-group" do
            html_options = bind_validators(klass, attr).merge({:class => 'tags'})
            form_object.hidden_field(attr.to_sym, html_options)
          end
        end

        c1 += %Q|
<script>
  $(document).ready(function() {
    $("##{id}").select2({
      tags: #{tags.to_json},
      width: 'resolve',
    });
  });
</script>
|.html_safe

        c1
      end
    end


    def render_select2_input(klass, attr, form_object, collection=nil, query_path=nil)
      id = [klass.name.underscore, attr].join('_')

      content_tag :div, :class => "form-group" do
        c1 = content_tag :label, :class => "col-sm-3 control-label", :for => id do
          klass.human_attribute_name(attr.to_sym)
        end

        c1 += content_tag :div, :class => "col-sm-6" do
          content_tag :div, :class => "input-group" do
            html_options = bind_validators(klass, attr).merge({:class => ''})
            form_object.input_field(attr.to_sym, html_options)
          end
        end

        if collection
          c1 += %Q|
<script>
  $(document).ready(function() {
    $("##{id}").select2({
      placeholder: '#{I18n.t('select_one')}',
      width: 'resolve',
      minimumInputLength: 1,
      data: #{collection.to_json},
    });
  });
</script>
|.html_safe
        else
          c1 += %Q|
<script>
  $(document).ready(function() {
    $("##{id}").select2({
      placeholder: '#{I18n.t('select_one')}',
      width: 'resolve',
      minimumInputLength: 1,
      ajax: {
        url: "#{query_path}.json",
        data: function (term, page) {
          return {
            q: term
          };
        },
        results: function (data, page) {
          return {results: data};
        },
      }
    });
  });
</script>
|.html_safe
        end

        c1
      end
    end

    def render_association_input(klass, attr, form_object, label_method=:name)
      association = attr.to_s.split('_').first.to_sym
      # if association == :entity
      #   render_select2_input(klass, attr, form_object, [])
      # else
        collection  = association.to_s.camelize.constantize.all.collect { |item| [item.send(label_method), item.id] }
        render_select_input(klass, attr, form_object, collection)
      # end
    end

    def render_datetime_input(klass, attr, form_object, time_format="%Y-%m-%d %H:%M:%S", js_time_format="yyyy-mm-dd hh:ii:ss", start_view='1', min_view='0')
      name = [klass.name.underscore, attr].join('_')

      content_tag :div, :class => "form-group" do
        c1 = content_tag :label, :class => "col-sm-3 control-label", :for => name do
          klass.human_attribute_name(attr.to_sym)
        end

        # default_datetime = form_object.object.send(attr.to_sym).strftime("%Y-%m-%dT%H:%M:%SZ")
        default_datetime = form_object.object.send(attr.to_sym).strftime(time_format) rescue Time.zone.now.strftime(time_format)

        c1 += content_tag :div, :class => "col-sm-6" do
          c2 = content_tag :div, :'data-date-format' => js_time_format, :'data-date' => default_datetime, :'data-start-view' => start_view, :'data-min-view' => min_view, :class => "input-group date datetime col-md-6 col-xs-7" do
            c3 = form_object.input_field attr.to_sym, bind_validators(klass, attr, {:class => 'form-control', :as => :string})
            c3 += content_tag :span, :class => 'input-group-addon btn-primary' do
              content_tag :span, :class => 'glyphicon glyphicon-th' do
              end
            end
            c3
          end
          c2 += content_tag :div, :id => "#{name}-error" do
          end

          c2
        end

        c1
      end
    end

    def render_date_input(klass, attr, form_object)
      render_datetime_input(klass, attr, form_object, "%Y-%m-%d", "yyyy-mm-dd", '2', '2')
    end

    def render_image_input(klass, attr, form_object)
      name = [klass.name.underscore, attr].join('_')

      content_tag :div, :class => "form-group" do
        c1 = content_tag :label, :class => "col-sm-3 control-label", :for => name do
          klass.human_attribute_name(attr.to_sym)
        end

        c1 += content_tag :div, :class => "col-sm-6" do
          c2 = content_tag :div, :'data-provides' => 'fileinput', :class => "fileinput fileinput-new" do
            c3 = ''
            if (url = form_object.object.send(attr.to_sym).url)
              c3 += content_tag :div, :class => 'fileinput-new thumbnail' do
                content_tag :img, :src => url, :width => 200 do
                end
              end
            end
            c3 += content_tag :div, :class => 'fileinput-preview fileinput-exists thumbnail', :style => 'max-width: 200px;' do
            end
            c3 += content_tag :div do
              c4 = content_tag :span, :class => 'btn btn-primary btn-file' do
                c5 = content_tag :span, :class => 'fileinput-new' do
                  I18n.t('choose_photo')
                end
                c5 += content_tag :span, :class => 'fileinput-exists' do
                  I18n.t('change')
                end
                c5 += form_object.input_field attr.to_sym, bind_validators(klass, attr, {:accept => "image/*", :class => ""})
                c5
              end
              c4 += content_tag :a, :'data-dismiss' => 'fileinput', :class => 'btn btn-danger fileinput-exists' do
                I18n.t('remove_photo')
              end
              c4
            end
            c3.html_safe
          end
          c2 += content_tag :div, :id => "#{name}-error" do
          end

          c2
        end

        c1
      end
    end

    def render_file_input(klass, attr, form_object)
      name = [klass.name.underscore, attr].join('_')

      content_tag :div, :class => "form-group" do
        c1 = content_tag :label, :class => "col-sm-3 control-label", :for => name do
          klass.human_attribute_name(attr.to_sym)
        end

        c1 += content_tag :div, :class => "col-sm-6" do
          c2 = content_tag :div, :'data-provides' => 'fileinput', :class => "fileinput fileinput-new" do
            c3 = ''
            if (url = form_object.object.send(attr.to_sym).url)
              c3 += content_tag :div, :class => 'fileinput-new thumbnail' do
                content_tag :img, :src => url, :width => 200 do
                end
              end
            end
            c3 += content_tag :div, :class => 'fileinput-preview fileinput-exists thumbnail', :style => 'max-width: 200px;' do
            end
            c3 += content_tag :div do
              c4 = content_tag :span, :class => 'btn btn-primary btn-file' do
                c5 = content_tag :span, :class => 'fileinput-new' do
                  I18n.t('choose_file')
                end
                c5 += content_tag :span, :class => 'fileinput-exists' do
                  I18n.t('change')
                end
                c5 += form_object.input_field attr.to_sym, bind_validators(klass, attr, {:class => ""})
                c5
              end
              c4 += content_tag :a, :'data-dismiss' => 'fileinput', :class => 'btn btn-danger fileinput-exists' do
                I18n.t('remove_file')
              end
              c4
            end
            c3.html_safe
          end
          c2 += content_tag :div, :id => "#{name}-error" do
          end

          c2
        end

        c1
      end

    end

  end
end
