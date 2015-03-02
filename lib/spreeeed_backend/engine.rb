module SpreeeedBackend
  require 'devise'
  require 'active_record_extension'

  class Engine < ::Rails::Engine
    isolate_namespace SpreeeedBackend

    config.autoload_paths << File.expand_path("../../lib", __FILE__)
  end
end
