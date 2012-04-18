class RefererTracking::Sweeper < ActionController::Caching::Sweeper
  def after_create(record)
    if session && session["referer_tracking"]
      ses = session["referer_tracking"]

      ref_mod = RefererTracking::RefererTracking.new(
          :trackable_id => record.id, :trackable_type => record.class.to_s)

      ses.each_pair do |key, value|
        ref_mod[key] = value if ref_mod.has_attribute?(key)
      end

      req = assigns(:referer_tracking_request_add_infos)
      if req && req.is_a?(Hash)
        req.each_pair do |key, value|
          ref_mod[key] = value if ref_mod.has_attribute?(key)
        end
      end


      ref_mod[:user_agent] = request.env['HTTP_USER_AGENT']
      ref_mod.save
    end

  rescue Exception => e
    Rails.logger.info "RefererTracking::Sweeper.after_create problem with creating record: #{e}"
  end
end

