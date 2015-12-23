# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "referer_tracking/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "referer_tracking"
  s.version     = RefererTracking::VERSION
  s.authors     = ["Olli Huotari"]
  s.email       = ["olli.huotari@iki.fi"]
  s.homepage    = "https://github.com/holli/referer_tracking/"
  s.summary     = "Referer tracking automates better tracking in your Rails app. It tells you who creates activerecord objects / models, where did they originally come from, what url did they use etc. It does it by saving referrer url to session and saving information about the request when creating new item. It enables you to optimize your web-app user interface and flow."
  s.description = "Referer tracking automates better tracking in your Rails app. It tells you who creates activerecord objects / models, where did they originally come from, what url did they use etc. It does it by saving referrer url to session and saving information about the request when creating new item. It enables you to optimize your web-app user interface and flow."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1"

  s.add_development_dependency "bundler", "~> 1.10"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mocha"
end
