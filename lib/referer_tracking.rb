require "referer_tracking/engine"

module RefererTracking

  mattr_accessor :save_cookies, :set_referer_cookies, :set_referer_cookies_name, :set_referer_cookies_first_url_max_length, :set_referer_cookies_ref_url_max_length, :use_observer_sweeper_if_found

  self.save_cookies = true
  self.set_referer_cookies = true
  self.set_referer_cookies_name = 'ref_track'
  self.set_referer_cookies_first_url_max_length = 400
  self.set_referer_cookies_ref_url_max_length = 200
  self.use_observer_sweeper_if_found = true # if you have gem 'rails-observers' included we will use sweepers to save infos

  mattr_accessor :add_observe_to_classes
  self.add_observe_to_classes = []
  def self.add_sweeper_model(model)
    unless RefererTracking.add_observe_to_classes.include?(model)
      RefererTracking.add_observe_to_classes.push(model)
      RefererTracking.copy_sweeper_models_to_sweeper
    end
  end

  def self.copy_sweeper_models_to_sweeper
    if defined?(RefererTracking::Sweeper) && RefererTracking.use_observer_sweeper_if_found
      RefererTracking::Sweeper.class_eval do
        observe RefererTracking.add_observe_to_classes
      end
      Rails.logger.info("RefererTracking sweeper observing classes #{RefererTracking::Sweeper.observed_classes}")
    end
  end

  module ActiveRecordExtension
    def has_referer_tracking
      has_one :referer_tracking, :class_name => "RefererTracking::RefererTracking", :as => :trackable
      RefererTracking.add_sweeper_model(self)
    end
  end


  class Railtie < Rails::Railtie
    initializer 'referer_tracking.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send(:extend, RefererTracking::ActiveRecordExtension)
      end
    end

    initializer 'referer_tracking.sweeper', :after => 'action_controller.caching.sweepers' do
      ActiveSupport.on_load(:action_controller) do
        if defined?(ActionController::Caching::Sweeper)
          require "referer_tracking/sweeper"
          RefererTracking.copy_sweeper_models_to_sweeper
        end
      end
    end

    initializer 'referer_tracking.sweeper', :after => 'action_controller.caching.sweepers' do
      ActiveSupport.on_load(:action_controller) do
        if defined?(ActionController::Caching::Sweeper) && RefererTracking.use_observer_sweeper_if_found
          require "referer_tracking/sweeper"
          RefererTracking.copy_sweeper_models_to_sweeper
        end
      end
    end

    initializer 'referer_tracking.controller_addons', :after => 'action_controller' do
      ActiveSupport.on_load(:action_controller) do
        require "referer_tracking/controller_addons"
      end
    end

  end

end

