# RefererTracking

Referer tracking automates better tracking in your Rails app. It tells you who creates
activerecord objects / models, where did they originally come from, what url did they use etc.
It does it by saving referrer url to session and saving information about the request when creating new item.
It enables you to optimize your web-app user interface and flow.

Http referer_url and first_url are saved to session in controller before_filter. When creating a new model these values are
saved to referer_trackings table. Also current request url and current request referer are saved.

You can query how specific objects were made by querying following. It will let you know how did the user end up in your page and where did he create the object.

```
  RefererTracking::RefererTracking.where(:trackable_type => 'class_name').collect{|rt| [rt.first_url, rt.referer_url, rt.current_request_referer_url]}
```

[<img src="https://secure.travis-ci.org/holli/referer_tracking.png" />](http://travis-ci.org/holli/referer_tracking)

## Monitored items

```
- session_referer_url - where did the user originally come from - saved in session
- session_first_url - what was the first url for this session - saved in session
- cookie_referer_url - where did the user originally come from - saved in persistent cookie
- cookie_first_url - where did the user originally come from - saved in persistent cookie
- cookie_time - at what time did the user originally come - saved in persistent cookie
- current_request_url - when creating the item
- current_request_referer_url - when creating the item, where did the request originate
- infos_session, infos_request - extra info you add by referer_tracking_add_info etc, see below
- user_agent, ip, session_id
- cookies_yaml - saves cookies if enabled in initializers with RefererTracking.save_cookies = true
               - handy for parsing information related to google analytics, e.g. number of visits
```


## Install

```
in /gemfile
  gem 'referer_tracking'

# Run following
# bundle
# bundle exec rake railties:install:migrations FROM=referer_tracking
# rake db:migrate

```

## Configure / Usage

```

class ApplicationController ... # in application_controller.rb
  include RefererTracking::ControllerAddons # saves first visit infos to session and cookie
end

class User < Activerecord::Base
  has_tracking
end

# By using sweepers
# also add to Gemfile "gem 'rails-observers'"
class UsersController
  # This monitors saved items and creates RefererTracking items in db, enable in controllers you want it to be used
  cache_sweeper RefererTracking::Sweeper
end

# Or by using custom methods
class UsersController
  def create
    @user = User.create
    referer_tracking_after_create(@user)
  end

  def login
    if @user.login_count == 10
      @user.tracking_add_log_line("10_logins")
    end
  end

end


/config/initializers/referer_tracking.rb # if you want to modify defaults, see https://github.com/holli/referer_tracking/blob/master/lib/referer_tracking.rb#L5
  RefererTracking.save_cookies = true # saves all cookies to db
  RefererTracking.set_referer_cookies = true # saves referer and first url data to cookie
                   # You should use it unless you are very performance minded : http://yuiblog.com/blog/2007/03/01/performance-research-part-3/

```

## Extras

You can add own info to referer_tracking table giving in your controller the value to referer_tracking.

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
- referer_tracking_add_info(key, value) # only set in the first time called - saved in session
- referer_tracking_set_info(key, value) # change value always - saved in session
- referer_tracking_get_key(key)
- referer_tracking_request_set_info
- referer_tracking_request_add_infos # hash of current request infos

## Inside

RefererTracking::ControllerAddons creates before_filter that saves referer_information to session. Direct access
is not recommended but possible with session[:referer_tracking]. Information is not saved for known bots.

## Requirements

Gem has been tested with latest Ruby and Rails combinations, see https://github.com/holli/referer_tracking/blob/master/.travis.yml for more info.

[<img src="https://secure.travis-ci.org/holli/referer_tracking.png" />](http://travis-ci.org/holli/referer_tracking)

## Other possible gems

- https://github.com/n8/devise_marketable

## Support

Submit suggestions or feature requests as a GitHub Issue or Pull Request. Remember to update tests. Tests are quite extensive.


## Licence

This project rocks and uses MIT-LICENSE. (http://www.opensource.org/licenses/mit-license.php)

