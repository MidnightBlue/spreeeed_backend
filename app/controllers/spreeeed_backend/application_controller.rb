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
    end

  end
end
