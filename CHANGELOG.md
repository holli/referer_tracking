## 5.0.1 (2026-09-08)

  - Fixed request strings reaching the session, the cookie, the log and the database as
    ASCII-8BIT. Rack tags every header value that way, so **any** non-ASCII referer or user
    agent — not just the invalid bytes crawlers send — made the database adapter refuse the
    write, and `referer_tracking_after_create` swallowed that: the tracking row silently went
    missing. The same bytes dropped the `REFERER_TRACKING_FIRST` log line, and on an app with
    `cookies_serializer :json` they raised in the cookie middleware and took the whole request
    down. Values are now scrubbed to UTF-8 as they are read from the request
  - Fixed the `cookies_yaml` fallback, whose `rescue` referred to an exception it never bound,
    so a cookie Psych could not dump lost the whole tracking row instead of the yaml
  - `before_action_referer_tracking_save_to_session` no longer lets its own errors reach the
    application; it logs them, as `referer_tracking_after_create` already did

## 5.0.0 (2026-08-30)

  - Dropped support for Rails < 7.1 and Ruby < 3.1
  - Added support for Rails 7.1, 7.2, 8.0, 8.1
  - Fixed `serialize :infos_session, Hash` style calls (positional coder removed in Rails 7.2),
    and pass an explicit `coder: YAML` so the gem works under `load_defaults 7.1`, which sets
    `active_record.default_column_serializer` to nil
  - Fixed `to_s(:db)` usages (removed in Rails 7.1)
  - **The session hash now uses string keys.** Rails 7.0 made `:json` the default
    `cookies_serializer` and JSON has no symbols, so the symbol keys this gem wrote came back as
    strings on the next request. `referer_tracking_get_info` then always returned nil, and
    `referer_tracking_add_info` — which only sets a key that isn't set yet — overwrote its value
    on every request instead of keeping the first one. Apps reading `session[:referer_tracking]`
    sub-keys, or `infos_session` keys, with symbols need to switch to strings

## 4.5.0 (2022-01-01)

  - Dropped support for rails 5.2 and old ruby

## 4.4.1 (2018-04-16)

  - Fixed so that too long user_agents wont cause exception

## 4.4.0 (2018-03-20)

  - Added Rails 5 support, dropped Rails 4

## 4.2.0 (2015-12-xx)

  - Removed usage of sweepers/observers. Tests were not reliable for enough. Better always use custom saving.

## 4.1.0 (2015-04-xx)

  - Renamed model from RefererTracking::RefererTracking to RefererTracking::Tracking
  - Using has_tracking inside models
  - Added status and log fields and methods, now we have model.tracking_add_log_line
     - Note: you have to run new migrations
  - Also added model.tracking.get_log_lines(/regexp/)
