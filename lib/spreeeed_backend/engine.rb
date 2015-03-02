module SpreeeedBackend
  require 'devise'

  class Engine < ::Rails::Engine
    isolate_namespace SpreeeedBackend

    # config.autoload_paths << File.expand_path("../lib/spreeeed_backend/active_record_extension", __FILE__)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

  end
end
