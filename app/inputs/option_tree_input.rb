class OptionTreeInput < SimpleForm::Inputs::Base
  def input
    klass         = options[:klass]
    input_name    = "#{object_name}[#{attribute_name}]"
    js_var_prefix = "kd_#{object_id}_#{attribute_name}"
    input_html_options.merge!({:style => "display:none;"})

    # if cache hit miss, force reload
    if klass.to_option_tree.nil? or klass.to_option_tree.empty?
      klass.to_option_tree(true)
    end

    option_tree = nil
    # if need to sort
    if @options[:sort_col] and @options[:sort_by]
      option_tree = klass.to_option_tree.sort_by_key(true) {|x, y| x.to_s <=> y.to_s}
    else
      option_tree = klass.to_option_tree
    end

    if @options[:last]
      last = option_tree.delete(@options[:last])
      option_tree.merge!({@options[:last] => last}) if last
    end

    option_tree_json   =  option_tree.to_json
    option_tree_config = {select_class: "select form-control"}
    # option_tree_config = {select_class: "#{input_html_options[:class].join(' ')}"}

    value = object.send(attribute_name.to_sym)
    if value
      option_tree_config[:preselect] = {:"#{input_name}" => klass.find_option_tree_path(klass.to_option_tree, value)}
    end

    option_tree_config.merge!(@options[:option_tree_config]) if @options[:option_tree_config]
    option_tree_config = option_tree_config.to_json


    extra_script = %Q|<script>var #{js_var_prefix}_config = #{option_tree_config}; var #{js_var_prefix}_option_tree = #{option_tree_json}; $('input[name="#{input_name}"]').optionTree(#{js_var_prefix}_option_tree, #{js_var_prefix}_config);</script>|

    # delete not html options
    input_html_options.delete(:klass)
    input_html_options.delete(:option_tree_config)
    input_html_options.delete(:class)

    ("#{@builder.text_field(attribute_name, input_html_options)} " + extra_script).html_safe
  end
end
