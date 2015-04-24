module RefererTracking::ActiveRecordExtension
  def has_referer_tracking
    has_one :tracking, :class_name => "RefererTracking::Tracking", :as => :trackable
    class_eval do
      delegate :add_log_line, to: :tracking, prefix: true, allow_nil: true
      delegate :'update_status', to: :tracking, prefix: true, allow_nil: true
    end

    RefererTracking.add_sweeper_model(self)
  end
end
