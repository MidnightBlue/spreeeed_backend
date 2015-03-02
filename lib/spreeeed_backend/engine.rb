module SpreeeedBackend
  require 'devise'
  require 'active_record_extension'

  class Engine < ::Rails::Engine
    isolate_namespace SpreeeedBackend
  end
end
