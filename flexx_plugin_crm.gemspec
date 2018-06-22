$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "flexx_plugin_crm/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "flexx_plugin_crm"
  s.version     = FlexxPluginCrm::VERSION
  s.authors     = ["Paulo Henrique Castro"]
  s.email       = ["phlcastro@gmail.com"]
  s.homepage    = ""
  s.summary     = ": Summary of FlexxPluginCrm."
  s.description = ": Description of FlexxPluginCrm."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "aasm", "~> 4.12.3"
  s.add_dependency "rails", "~> 4.2.10"
  s.add_dependency "sendgrid-ruby", "~> 5.2.0"
  s.add_dependency "acts-as-taggable-on", "~> 5.0"
end
