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
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    isolate_namespace SpreeeedBackend
  end
end
