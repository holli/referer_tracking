# RefererTracking

Referer tracking is saves referrer url to session and automates better tracking of who creates models in your Rails app.

Http referer_url and first_url are saved to session in controller before_filter. When creating a new model these values are
saved to referer_trackings table.

# Install / Usage

## Install

```
in /gemfile
  gem 'referer_tracking'

# Run following
# bundle
# bundle exec rake railties:install:migrations FROM=RefererTracking
# rake db:migrate

```

## Configure

```

ApplicationController
  include RefererTracking::ControllerAddons
end

OtherController
  # This monitors saved items, enable in controllers you want it to be used
  cache_sweeper RefererTracking::Sweeper
end

/config/initializers/referer_tracking.rb
  # Referer tracking is enabled for these models
  RefererTracking.add_tracking_to(User)

```

## Extras

You can add own info to referer_tracking table by creating a column in the table and in your controller giving the
value to referer_tracking.

```

UserController
  # Example of adding info to referer_tracking, remember to create migration to add column first
  before_filter do |controller|
    
  end
end

```


# Licence

This project rocks and uses MIT-LICENSE. (http://www.opensource.org/licenses/mit-license.php)

