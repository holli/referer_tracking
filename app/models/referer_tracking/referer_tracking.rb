module RefererTracking
  class RefererTracking < ActiveRecord::Base
    belongs_to :trackable, :polymorphic => true
  end
end
