module RefererTracking
  class RefererTracking < ActiveRecord::Base
    self.table_name = "referer_trackings"
    belongs_to :trackable, :polymorphic => true
    serialize :infos_session, Hash
    serialize :infos_request, Hash
  end
end
