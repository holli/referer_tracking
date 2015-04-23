class User < ActiveRecord::Base
  attr_accessible :name

  has_tracking
end
