module SpreeeedBackend
  require 'devise'

  class Engine < ::Rails::Engine
    isolate_namespace SpreeeedBackend

    require_dependency 'lib/spreeeed_backend/active_record_extension'

  end
end
