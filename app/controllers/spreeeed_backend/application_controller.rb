module SpreeeedBackend
  class ApplicationController < ActionController::Base
    layout 'spreeeed_backend/backend'

    protect_from_forgery

    PER_PAGE = 30

    before_filter :authenticate_user!, :setup_global_variables

    def index
    end

  end
end
