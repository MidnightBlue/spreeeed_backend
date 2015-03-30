module SpreeeedBackend
  require 'devise'
  require 'bootstrap-will_paginate'
  require 'simple_form'
  require 'cocoon'

  require 'spreeeed_backend/active_record_extend'

  class << self
    mattr_accessor :name_space
    self.name_space           = 'backend'
    self.devise_auth_resource = 'user'
  end

  def self.setup(&block)
    yield self
  end

  class Engine < ::Rails::Engine
    config.time_zone = 'Taipei'

    config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]
    config.i18n.available_locales ||= [:'zh-TW']
    config.i18n.default_locale = :'zh-TW'

    initializer "SpreeeedBackend.assets.precompile" do |app|
      app.config.assets.precompile += %w(index.css style.css index.js)
    end

    isolate_namespace SpreeeedBackend
  end
end
