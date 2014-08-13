# Since ActionController::Caching::Sweeper was removed from rails core in 4
# and moved to gem rails-observers, we have trouble loading stuff in the right order
# (see lib/referer_tracking/sweeper.rb).
# Manually loading these here fixes the problem for now:
require "rails/observers/activerecord/active_record"
require "rails/observers/action_controller/caching"

require "referer_tracking/engine"
require "referer_tracking/controller_addons"
require "referer_tracking/sweeper"

module RefererTracking

  mattr_accessor :save_cookies, :set_referer_cookies, :set_referer_cookies_name, :set_referer_cookies_first_url_max_length, :set_referer_cookies_ref_url_max_length

  self.save_cookies = true
  self.set_referer_cookies = true
  self.set_referer_cookies_name = 'ref_track'
  self.set_referer_cookies_first_url_max_length = 400
  self.set_referer_cookies_ref_url_max_length = 200

  def self.add_tracking_to(*models_list)
    models_list.each do |model|
      model.class_eval do
        include RefererTracking::TrackableModule
      end
    end

    RefererTracking::Sweeper.class_eval do
      observe models_list
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
