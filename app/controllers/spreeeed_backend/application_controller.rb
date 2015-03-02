module SpreeeedBackend
  class ApplicationController < ActionController::Base
    layout 'spreeeed_backend/backend'

    protect_from_forgery

    PER_PAGE = 30

    before_filter :authenticate_user!, :setup_global_variables

    def setup_global_variables
      @klass            ||= NilClass
      @klass_name       = @klass.name
      @displayable_cols = (@klass_name == 'NilClass' ? [] : @klass.displayable_cols)
      @editable_cols    = (@klass_name == 'NilClass' ? [] : @klass.editable_cols)
      @nested_cols      = (@klass_name == 'NilClass' ? [] : @klass.nested_cols)
      @hidden_cols      = (@klass_name == 'NilClass' ? [] : @klass.hidden_cols)
    end

    def index
      per_page         = params[:iDisplayLength] || PER_PAGE
      page             = (params[:iDisplayStart].to_i / per_page.to_i) + 1

      @datatable_id    = "#{@klass_name.underscore.pluralize}_datatable"
      @datatable_cols  = datatable_cols(@klass.new, @attrs)
      @sortable_cols   = render_sortable_cols(@klass, @attrs)

      sort_col         = @attrs[params[:iSortCol_0].to_i] || 'id'
      sort_col         = "#{sort_col}_id" if @klass.belongs_to_associations.include?(sort_col)
      sortby           = params[:sSortDir_0] || "desc"

      if params[:sSearch].present?
        q          = params[:sSearch]
        @instances = @klass.where(searchable_conditions(@searchable_cols, q)).order("#{sort_col} #{sortby}").paginate(:page => page, :per_page => per_page)
        total      = @klass.where(searchable_conditions(@searchable_cols, q)).count
      else
        @instances = @klass.order("#{sort_col} #{sortby}").paginate(:page => page, :per_page => per_page)
        total      = @klass.count
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: render_datatable_data(@instances, @attrs, page, total) }
      end
    end

  end
end
