$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "referer_tracking/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "referer_tracking"
  s.version     = RefererTracking::VERSION
  s.authors     = ["Olli Huotari"]
  s.email       = ["olli.huotari@iki.fi"]
  s.homepage    = "https://github.com/holli/referer_tracking/"
  s.summary     = "Referer tracking is saves referrer url to session and automates better tracking of who creates models in your Rails app. Http referer_url and first_url are saved to session in controller before_filter. When creating a new model these values are saved to referer_trackings table."
  s.description = "Referer tracking is saves referrer url to session and automates better tracking of who creates models in your Rails app. Http referer_url and first_url are saved to session in controller before_filter. When creating a new model these values are saved to referer_trackings table."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mocha"
  
end
