module SpreeeedBackend
  require 'devise'
  require 'bootstrap-will_paginate'

  require 'spreeeed_backend/active_record_extend'

  class Engine < ::Rails::Engine
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    isolate_namespace SpreeeedBackend
  end
end
