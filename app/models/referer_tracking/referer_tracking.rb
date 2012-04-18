module RefererTracking
  class RefererTracking < ActiveRecord::Base
    set_table_name "referer_trackings"
    belongs_to :trackable, :polymorphic => true
  end
end
