class RefererTracking::Sweeper < ActionController::Caching::Sweeper
  def after_create(record)
    if session && session["referer_tracking"]
      ses = session["referer_tracking"]

      ref_mod = RefererTracking::RefererTracking.new(
          :trackable_id => record.id, :trackable_type => record.class.to_s)

      ses.each_pair do |key, value|
        ref_mod[key] = value if ref_mod.has_attribute?(key)
        ref_mod.infos_session[key] = value unless [:session_referer_url, :session_first_url].include?(key)
      end

      req = assigns(:referer_tracking_request_add_infos)
      if req && req.is_a?(Hash)
        req.each_pair do |key, value|
          ref_mod[key] = value if ref_mod.has_attribute?(key)
          ref_mod.infos_request[key] = value
        end
      end

      ref_mod[:ip] = request.ip
      ref_mod[:user_agent] = request.env['HTTP_USER_AGENT']
      ref_mod[:current_request_url] = request.url
      ref_mod[:current_request_referer_url] = request.env["HTTP_REFERER"] # or request.headers["HTTP_REFERER"]
      ref_mod[:session_id] = request.session["session_id"]

      unless cookies[RefererTracking.set_referer_cookies_name].blank?
        cookie_ver, cookie_time_org, cookie_first_url, cookie_referer_url = cookies[RefererTracking.set_referer_cookies_name].to_s.split("|||")
        ref_mod[:cookie_first_url] = RefererTracking::Sweeper.try_to_parse(cookie_first_url)
        ref_mod[:cookie_referer_url] = RefererTracking::Sweeper.try_to_parse(cookie_referer_url)
        ref_mod[:cookie_time] = Time.at(cookie_time_org.to_i)
      end

      if RefererTracking.save_cookies
        begin
          ref_mod[:cookies_yaml] = cookies.instance_variable_get('@cookies').to_yaml
        rescue
          str = "referer_tracking after create problem encoding cookie yml, probably non utf8 chars #{e}"
          logger.error(str)
          ref_mod[:cookies_yaml] = "error: #{str}"
        end
      end

      ref_mod.save
    end

  rescue Exception => e
    Rails.logger.info "RefererTracking::Sweeper.after_create problem with creating record: #{e}"
  end

  def self.try_to_parse(url)
    orig_url = url
    rescued = false
    err_count = 0
    err_limit = 4
    loop do
      err = false
      begin
        URI.parse(url)
      rescue URI::InvalidURIError
        rescued = true
        err = true
        err_count+= 1
        url = url[0...-1]
      end
      break if !err or err_count == err_limit
    end
    if(rescued && defined? logger) then logger.info("failed parsing with url: " +orig_url) end
    return (err_count == err_limit) ? orig_url : url
  end
end

