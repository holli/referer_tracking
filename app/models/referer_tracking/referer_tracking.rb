module RefererTracking
  class RefererTracking < ActiveRecord::Base
    self.table_name = "referer_trackings"
    belongs_to :trackable, :polymorphic => true
  end
end
