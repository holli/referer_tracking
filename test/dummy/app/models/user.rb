class User < ActiveRecord::Base
  attr_accessible :name

  has_referer_tracking

  #delegate :add_log_line, to: :tracking, prefix: true, allow_nil: true
end
