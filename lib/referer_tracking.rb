require "referer_tracking/engine"
require "referer_tracking/controller_addons"
require "referer_tracking/sweeper"

module RefererTracking

  def self.add_tracking_to(*models_list)
    models_list.each do |model|
      model.class_eval do
        include RefererTracking::TrackableModule
      end

      RefererTracking::Sweeper.class_eval do
        observe model
      end
      
    end
  end

  module TrackableModule
    def self.included(base)
      base.class_eval do
        has_one :referer_tracking, :class_name => "RefererTracking::RefererTracking", :as => :trackable
      end
    end
  end
  
end
