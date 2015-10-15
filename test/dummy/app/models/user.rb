class User < ActiveRecord::Base
  has_referer_tracking

  #delegate :add_log_line, to: :tracking, prefix: true, allow_nil: true
end
