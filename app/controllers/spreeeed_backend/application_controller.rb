module SpreeeedBackend
  class ApplicationController < ActionController::Base

    def index
      render :text => 'Hello World!'
    end

  end
end
