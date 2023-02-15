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
