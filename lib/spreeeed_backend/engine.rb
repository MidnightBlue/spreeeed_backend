module SpreeeedBackend
  require 'devise'
  require 'bootstrap-will_paginate'

  require 'spreeeed_backend/active_record_extend'

  class << self
    mattr_accessor :name_space
    self.name_space = 'backend'
  end

  def self.setup(&block)
    yield self
  end

  class Engine < ::Rails::Engine
    # config.autoload_paths += Dir["#{config.root}/lib/**/"]
    # config.autoload_paths += Dir["#{config.root}/config/locales/**/"]

    initializer "my_engine.configure_i18n_initialization" do |config|
      config.time_zone = 'Taipei'
      config.i18n.load_path += Dir["#{config.root}/config/locales/**/"]
      config.i18n.available_locales ||= [:'zh-TW']
      config.i18n.default_locale = :'zh-TW'
    end

    isolate_namespace SpreeeedBackend
  end
end
