Gem::Specification.new do |s|
  s.name        = "flexx_plugin_crm"
  s.version     = "0.0.1"
  s.authors     = ["Paulo Henrique Castro"]
  s.email       = ["phlcastro@gmail.com"]
  s.homepage    = ""
  s.summary     = ": Summary of FlexxPluginCrm."
  s.description = ": Description of FlexxPluginCrm."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "aasm", "~> 5.0.1"
  s.add_dependency "acts-as-taggable-on", "~> 5.0"
  s.add_dependency "cama_contact_form", "~> 0.0.23"
  s.add_dependency "camaleon_cms", "~> 2.4.3.8"
  s.add_dependency "json", "~> 1.7", ">= 1.7.7"
  s.add_dependency "mustache", "~> 1.1.0"
  s.add_dependency "rails", "~> 4.2.10"
  s.add_dependency "sendgrid-ruby", "~> 5.2.0"
  s.add_dependency "sidekiq", "~> 5.2.2"
  s.add_dependency "stream-ruby", "~> 3.1.0"
  s.add_dependency "timezone", "~> 1.0"
  s.add_dependency "twilio-ruby", "~> 5.10", ">= 5.10.5"


  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'figaro'
  s.add_development_dependency 'pg', '~>0.15'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'rspec-rails', '~>3.8'
  s.add_development_dependency 'rspec-sidekiq'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
end
