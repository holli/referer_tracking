class RefererTracking::Sweeper < ActionController::Caching::Sweeper
  # https://github.com/rails/rails-observers/blob/master/lib/rails/observers/active_model/observing.rb

  def after_create(record)
    if controller && controller.method_exists?(:referer_tracking_after_create)
      controller.referer_tracking_after_create(record)
    end
  end

end

