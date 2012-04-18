# RefererTracking

Referer tracking is saves referrer url to session and automates better tracking of who creates models in your Rails app.

Http referer_url and first_url are saved to session in controller before_filter. When creating a new model these values are
saved to referer_trackings table.

[<img src="https://secure.travis-ci.org/holli/referer_tracking.png" />](http://travis-ci.org/holli/referer_tracking)

## Install

```
in /gemfile
  gem 'referer_tracking'

# Run following
# bundle
# bundle exec rake railties:install:migrations FROM=referer_tracking
# rake db:migrate

```

## Configure

```

ApplicationController
  include RefererTracking::ControllerAddons
end

OtherController
  # This monitors saved items and creates RefererTracking items in db, enable in controllers you want it to be used
  cache_sweeper RefererTracking::Sweeper
end

/config/initializers/referer_tracking.rb
  # Referer tracking is enabled for these models
  RefererTracking.add_tracking_to(User)
  # RefererTracking.add_tracking_to(User, Messages) # for multiple models

```

## Extras

You can add own info to referer_tracking table by creating a column in the table and in your controller giving the
value to referer_tracking.

```
UserController
  # Example of adding info to referer_tracking, remember to create migration to add column first
  before_filter do |controller|
    # adds to session, so saved to later requests
    referer_tracking_add_info('referer_id', session[:referer_id])

    # adds only to this requests, ignored later
    referer_tracking_request_set_info('referer_id', session[:referer_id])
  end

end

```

**Helpers include**

- referer_tracking_first_request?
- referer_tracking_add_info(key, value) # only set in the first time called
- referer_tracking_set_info(key, value) # change value always
- referer_tracking_get_key(key)
- referer_tracking_request_set_info
- referer_tracking_request_add_infos # hash of current request infos

## Inside

RefererTracking::ControllerAddons creates before_filter that saves referer_information to session. Direct access
is not recommended but possible with session[:referer_tracking]. Information is not saved for known bots.

## Requirements

Gem has been tested with ruby 1.8.7, 1.9.2 and Rails 3.1.

[<img src="https://secure.travis-ci.org/holli/referer_tracking.png" />](http://travis-ci.org/holli/referer_tracking)


## Support

Submit suggestions or feature requests as a GitHub Issue or Pull Request. Remember to update tests. Tests are quite extensive.


## Licence

This project rocks and uses MIT-LICENSE. (http://www.opensource.org/licenses/mit-license.php)

