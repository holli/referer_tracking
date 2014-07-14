module RefererTracking
  class RefererTracking < ActiveRecord::Base
    self.table_name = "referer_trackings"
    belongs_to :trackable, :polymorphic => true
    serialize :infos_session, Hash
    serialize :infos_request, Hash
    attr_accessible :trackable_id, :trackable_type, :cookie_referer_url, :cookie_first_url, :user_agent, :cookies_yaml, :current_request_referer_url

    def first_url_combined
      cookie_first_url || session_first_url
    end
    def referer_url_combined
      cookie_referer_url || session_referer_url
    end
  end
end
