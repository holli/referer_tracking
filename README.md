# RefererTracking

Referer tracking automates better tracking in your Rails app. It tells you who creates
activerecord objects / models, where did they originally come from (http referrer), what url did they use etc.
It does it by saving referrer url to session and saving information about the request when creating new item.

Also includes tools to add log lines to models to get better information about the flow of the users or which A/B testing variation was used for which model. Aim is to make data collection for model creation, A/B-testing and growth hacking easier.

[<img src="https://secure.travis-ci.org/holli/referer_tracking.png" />](http://travis-ci.org/holli/referer_tracking)

## Example use cases

```
- Example configuration
- In UsersController.create
  - referer_tracking_after_create(@user) # saves all referrer etc information
  - @user.tracking_add_log_line('signup_ab_testing_b_variation') # having ab testing? Mark where user is going
- In SessionsController.create
  - @user.tracking_add_log_line('10:th login')
- In some scheduled script
  - @user.tracking_update_status('active') if @user.login_count > 10 && @user.blog_posts.count > 1
```

Later you can query how specific objects were made. It will let you know how did the user end up in your page and where did he create the object. This gem helps you to save data. But you still have to do the queries scripts yourself.

**How about last 100 objects with information about first pages (landing pages) and their flow**

```
RefererTracking::Tracking.where(:trackable_type => 'User').last(100).collect{|tracking| [tracking.first_url, tracking.referer_url, tracking.current_request_referer_url]}
# [['http://mysite.com/landing_page_01', 'http://google.com/...', 'http://mysite.com/signup_v01/hello'] ... ]
```

**How does a specific landing page work**

```
landing_a = RefererTracking::Tracking.where(:trackable_type => 'User').find_all{|tracking| tracking.first_url.match(/yourdomain.com\/landing_page_b/)}
puts landing_a.collect{|tracking| tracking.trackable.name}
   - instead of just looking creation numbers you can also see who came from there and how fast did they do their 10:th login
```

**Checking if some flow results in better conversion than other**

```
variation_a = RefererTracking::Tracking.where(:trackable_type => 'User').find_all{|tracking| tracking.get_log_lines('signup_ab_testing_a_variation')}
variation_b = RefererTracking::Tracking.where(:trackable_type => 'User').find_all{|tracking| tracking.get_log_lines('signup_ab_testing_b_variation')}
puts "var_a: #{variation_a.size}, active count #{variation_a.count{|tracking| tracking.status == 'active'}"
puts "var_b: #{variation_b.size}, active count #{variation_b.count{|tracking| tracking.status == 'active'}"
```

**Or maybe checking how user_agent affects conversion**

```
RefererTracking::Tracking.where(:trackable_type => 'User').find_all{|tracking| tracking.user_agent.to_s.include?('Android')}
```



## Automatically monitored items

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
- status - use by model.tracking_update_status('active') etc to add information
- log - so you can add lines later
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

- **In Controllers**
  - referer_tracking_first_request?
  - referer_tracking_add_info(key, value) # only set in the first time called - saved in session
  - referer_tracking_set_info(key, value) # change value always - saved in session
  - referer_tracking_get_key(key)
  - referer_tracking_request_set_info
  - referer_tracking_request_add_infos # hash of current request infos
- **In Models** (E.g. when including in user-model)
  - user.tracking_update_status('active')
  - user.tracking_add_log_line('10:th login') # e.g. to track users flow
  - user.tracking.get_log_lines(/login/) # results all log lines matching regexp

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

