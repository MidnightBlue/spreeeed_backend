module SpreeeedBackend
  require 'devise'

  class Engine < ::Rails::Engine
    isolate_namespace SpreeeedBackend

    require 'active_record_extension'
  end
end
