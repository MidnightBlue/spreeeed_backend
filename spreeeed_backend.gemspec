$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "spreeeed_backend/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spreeeed_backend"
  s.version     = SpreeeedBackend::VERSION
  s.authors     = ["Bruce Sung"]
  s.email       = ["isfore@gmail.com"]
  s.homepage    = "https://github.com/MidnightBlue/spreeeed_backend"
  s.summary     = "This is a backend engine made by Spreeeed"
  s.description = "This is a backend engine made by Spreeeed"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.22"
  s.add_dependency "jquery-rails"
  s.add_dependency "devise", "3.0.3"
  s.add_dependency "bootstrap-will_paginate", "0.0.10"
  s.add_dependency "i18n"
  s.add_dependency 'simple_form', '2.1.3'
  s.add_dependency "cocoon", '1.2.0'


  # s.add_development_dependency "rails-assets-bootstrap"
  # s.add_development_dependency "sqlite3"
end
