require "referer_tracking/engine"

module RefererTracking

  mattr_accessor :save_cookies, :set_referer_cookies, :set_referer_cookies_name, :set_referer_cookies_first_url_max_length, :set_referer_cookies_ref_url_max_length

  self.save_cookies = true
  self.set_referer_cookies = true
  self.set_referer_cookies_name = 'ref_track'
  self.set_referer_cookies_first_url_max_length = 400
  self.set_referer_cookies_ref_url_max_length = 200

  class Railtie < Rails::Railtie
    initializer 'referer_tracking.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        require 'referer_tracking/active_record_extensions'
        ActiveRecord::Base.send(:extend, RefererTracking::ActiveRecordExtension)
      end
    end

    initializer 'referer_tracking.controller_addons', :after => 'action_controller' do
      ActiveSupport.on_load(:action_controller) do
        require "referer_tracking/controller_addons"
      end
    end

  end

end

