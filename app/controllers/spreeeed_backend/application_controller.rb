module SpreeeedBackend
  class ApplicationController < ActionController::Base
    layout 'spreeeed_backend/backend'

    protect_from_forgery

    PER_PAGE = 30

    before_filter :"authenticate_#{SpreeeedBackend.devise_auth_resource}!", :setup_global_variables

    def setup_global_variables
      @klass             ||= NilClass
      @klass_name        = @klass.name
      @displayable_cols  = (@klass_name == 'NilClass' ? [] : @klass.displayable_cols)
      @editable_cols     = (@klass_name == 'NilClass' ? [] : @klass.editable_cols)
      @nested_cols       = (@klass_name == 'NilClass' ? [] : @klass.nested_cols)
      @hidden_cols       = (@klass_name == 'NilClass' ? [] : @klass.hidden_cols)
      @default_sort_cols = []
    end

    def index
      per_page         = params[:iDisplayLength] || PER_PAGE
      page             = (params[:iDisplayStart].to_i / per_page.to_i) + 1

      @datatable_id    = "#{@klass_name.underscore.pluralize}_datatable"
      @datatable_cols  = datatable_cols(@klass.new, @attrs)
      @sortable_cols   = render_sortable_cols(@klass, @attrs)


      sort_cols        = []
      if params[:iSortCol_0].present?
        sort_col         = @attrs[params[:iSortCol_0].to_i] || 'id'
        sort_col         = "#{sort_col}_id" if @klass.belongs_to_associations.include?(sort_col)
        sort_by          = params[:sSortDir_0] ? params[:sSortDir_0] : 'ASC'
        sort_cols        << [sort_col, sort_by]
      else
        sort_cols        = @klass.default_sort_cols
      end

      @default_sort_cols = render_default_sort_cols(sort_cols, @attrs)

      if params[:sSearch].present?
        q          = params[:sSearch]
        @instances = @klass.where(searchable_conditions(@searchable_cols, q)).order(order_conditions(sort_cols)).paginate(:page => page, :per_page => per_page)
        total      = @klass.where(searchable_conditions(@searchable_cols, q)).count
      else
        @instances = @klass.order(order_conditions(sort_cols)).paginate(:page => page, :per_page => per_page)
        total      = @klass.count
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: render_datatable_data(@instances, @attrs, page, total) }
      end
    end

    def show
      @object = @klass.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @object }
      end
    end

    def new
      @object = @klass.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @object }
      end
    end

    def edit
      @object = @klass.find(params[:id])
    end

    def create
      @object = @klass.new(params[@klass_name.underscore.to_sym])

      respond_to do |format|
        if @object.save
          format.html { redirect_to [SpreeeedBackend.name_space.to_sym, @object], notice: "#{@klass_name} was successfully created." }
          format.json { render json: @object, status: :created, location: @object }
        else
          format.html { render action: "new" }
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      @object = @klass.find(params[:id])

      respond_to do |format|
        if @object.update_attributes(params[@klass_name.underscore.to_sym])
          format.html { redirect_to [SpreeeedBackend.name_space.to_sym, @object], notice: "#{@klass_name} was successfully updated." }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @object = @klass.find(params[:id])
      @object.destroy

      respond_to do |format|
        format.html { redirect_to send("#{SpreeeedBackend.name_space}_#{@klass_name.underscore.pluralize}_url") }
        format.json { head :no_content }
      end
    end





    protected

    def datatable_value(object, attr)
      if object.id.present?
        object_name = object.class.to_s.underscore
        value       = object.send(attr.to_sym)
        if [:id, :name, :title, :subject, :content].include?(attr.to_sym)
          object_path = self.send("#{SpreeeedBackend.name_space}_#{object_name}_path", object.id)
          view_context.link_to(value, object_path, {:target => '_blank'})
        elsif object.class.belongs_to_associations.includes(attr)
          if value.respond_to(:name)
            datatable_value(value, :name)
          else
            datatable_value(value, :id)
          end
        elsif attr.to_s == 'aasm_state'
          view_context.display_state(object, attr)
        elsif value.kind_of?(Date)
          value.strftime("%Y/%m/%d")
          # view_context.send(attr, object)
        elsif value.kind_of?(Integer)
          view_context.number_with_delimiter(value)
        elsif value.kind_of?(TrueClass)
          view_context.yes_or_no(value)
        elsif value.kind_of?(FalseClass)
          view_context.yes_or_no(value)
        elsif value.kind_of?(Time)
          value.strftime("%Y/%m/%d %H:%M")
        else
          value
        end
      else
        nil
      end
    end

    def render_sortable_cols(klass, attrs)
      sortable_cols = []
      if klass.sortable_cols.kind_of?(ActiveSupport::OrderedHash)
        sortable_cols = klass.sortable_cols.collect { |label, _attrs| _attrs }.flatten
      elsif klass.sortable_cols.kind_of?(Array)
        sortable_cols = klass.sortable_cols
      else

      end

      Rails.logger.debug("==== #{sortable_cols.inspect}")

      res = attrs.collect { |attr|
        {'bSortable' => sortable_cols.include?(attr)}
      }
      Rails.logger.debug("==== #{res}")
      res
    end

    def render_default_sort_cols(sort_cols, attrs)
      res = []
      sort_cols.each do |sort_col|
        if i = attrs.index(sort_col[0])
          res << [i, sort_col[1]]
        end
      end
      res
    end

    def datatable_cols(object, attrs)
      datatable_mapping(object, attrs).collect{ |col| col[:label]}
    end

    def datatable_col_defs(object, attrs)
      res = []
      attrs.each do |attr|
        res << {
            :sTitle    => object.class.human_attribute_name(attr.to_sym),
            :bSortable => datatable_sortable(object, attr),
        }
      end
    end

    def datatable_mapping(object, attrs)
      res = []
      attrs.each do |attr|
        res << {
            :label => object.class.human_attribute_name(attr.to_sym),
            :attr  => attr,
            :value => datatable_value(object, attr),
        }
      end

      res
    end

    def searchable_conditions(searchable_cols, q)
      res        = []
      conditions = []
      searchable_cols.each do |col|
        conditions << "#{col} ILIKE ?"
        res << "%#{q}%"
      end
      [conditions.join(' OR ')] + res
    end

    def order_conditions(sort_cols)
      sort_cols.collect{ |sort_col| "#{sort_col[0]} #{sort_col[1]}"}.join(', ')
    end

    def render_datatable_data(objects, attrs, page, total)
      i = (page.to_i - 1) * 10

      # aoColumns = []
      aaData = objects.collect{ |object|
        datatable_mapping(object, attrs).collect do |col|
          col[:value]
        end
        # aoColumns = datatable_col_defs(object, attrs) if aoColumns.empty?
      }

      {
          "sEcho"                => params[:sEcho],
          "iTotalRecords"        => total,
          "iTotalDisplayRecords" => total,
          "aaData"               => aaData,
          # "aoColumns"            => aoColumns,
      }
    end

  end
end
