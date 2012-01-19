# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


#silence_stream(STDOUT) do
#  ActiveRecord::Migrator.migrate File.expand_path('../../db/migrate/', __FILE__)
#  ActiveRecord::Migrator.migrate File.expand_path('../dummy/db/migrate/', __FILE__)
#end
