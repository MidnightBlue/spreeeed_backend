module SpreeeedBackend
  require 'devise'
  require 'spreeeed_backend/active_record_extend'

  class Engine < ::Rails::Engine
    # config.autoload_paths << File.expand_path("../lib/spreeeed_backend/active_record_extension", __FILE__)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    puts config.root



    isolate_namespace SpreeeedBackend
  end
end
