## 4.2.0 (2015-12-xx)

  - Removed usage of sweepers/observers. Tests were not reliable for enough. Better always use custom saving.

## 4.1.0 (2015-04-xx)

  - Renamed model from RefererTracking::RefererTracking to RefererTracking::Tracking
  - Using has_tracking inside models
  - Added status and log fields and methods, now we have model.tracking_add_log_line
     - Note: you have to run new migrations
  - Also added model.tracking.get_log_lines(/regexp/)
