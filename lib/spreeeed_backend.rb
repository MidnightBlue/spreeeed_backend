require "spreeeed_backend/engine"

module SpreeeedBackend
  class Engine < Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w{ spreeeed_backend.js }
      Rails.application.config.assets.precompile += %w{ spreeeed_backend.css }
      Rails.application.config.assets.paths << root.join("app", "assets")
    end

  end
end
