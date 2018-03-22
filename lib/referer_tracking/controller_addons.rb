module RefererTracking::ControllerAddons

  #before_filter :before_filter_referer_tracking_save_to_session

  def before_action_referer_tracking_save_to_session
    unless request_is_from_a_known_bot?
      if session[:referer_tracking].nil?
        @referer_tracking_first_request = true
        session[:referer_tracking] = hash = Hash.new

        request_ref = "unknown"
        request_ref = request.headers["HTTP_REFERER"] if !request.headers["HTTP_REFERER"].blank?

        request_ref = request_ref.to_s.gsub(/pass(word)?=[^&]+/, 'pass=xxxx')
        first_url = request.url.to_s.gsub(/pass(word)?=[^&]+/, 'pass=xxxx')

        hash[:session_referer_url] = request_ref
        hash[:session_first_url] = first_url

        if RefererTracking.set_referer_cookies && cookies[RefererTracking.set_referer_cookies_name].nil?
          cookie_info = "v01|||#{Time.now.utc.to_i}|||#{first_url.first(RefererTracking.set_referer_cookies_first_url_max_length)}|||#{request_ref.first(RefererTracking.set_referer_cookies_ref_url_max_length)}"
          cookies[RefererTracking.set_referer_cookies_name] = { :value => cookie_info, :expires => 5.years.from_now, :domain => :all }
        end

        logger.info( "REFERER_TRACKING_FIRST: ver04 (ref|first) ||| #{hash[:session_referer_url]} ||| #{hash[:session_first_url]}" )
      end

    end
  end

  def referer_tracking_after_create(record)
    @referer_tracking_saved_records = [] if @referer_tracking_saved_records.nil?
    if session && session["referer_tracking"]
      ses = session["referer_tracking"]

      ref_mod = @referer_tracking_saved_records.find { |ref_mod| ref_mod.trackable == record || (record.id && ref_mod.trackable_id == record.id && ref_mod.trackable_type == record.class.to_s) }
      if ref_mod.nil?
        #ref_mod = RefererTracking::Tracking.new(:trackable_id => record.id, :trackable_type => record.class.to_s)
        ref_mod = record.build_tracking
        @referer_tracking_saved_records.push(ref_mod)
      end

      ses.each_pair do |key, value|
        ref_mod[key] = value if ref_mod.has_attribute?(key)
        ref_mod.infos_session[key] = value unless [:session_referer_url, :session_first_url].include?(key)
      end

      req = @referer_tracking_request_add_infos
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
        ref_mod[:cookie_first_url] = cookie_first_url
        ref_mod[:cookie_referer_url] = cookie_referer_url
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

      ref_mod.save unless ref_mod.trackable.new_record?
    end

  rescue Exception => e
    Rails.logger.info "RefererTracking::ControllerAddons.after_create problem with creating record: #{e}"
  end

  ###############################################
  # Session add methods

  # Add only if referer_tracking already in session and key has not been added/changed before
  # So this is only performed on the first time of the session
  def referer_tracking_add_info(key, value)
    if !session[:referer_tracking].nil? && session[:referer_tracking][key.to_sym].nil?
      referer_tracking_set_info(key, value)
    end
  end

  def referer_tracking_set_info(key, value)
    if !session[:referer_tracking].nil?
      session[:referer_tracking][key.to_sym] = value
    end
  end

  def referer_tracking_get_info(key)
    session[:referer_tracking].nil? ? nil : session[:referer_tracking][key.to_sym]
  end

  ###############################################
  # Request add methods

  def referer_tracking_request_add_infos
    @referer_tracking_request_add_infos ||= {}
  end
  private :referer_tracking_request_add_infos

  def referer_tracking_request_set_info(key, value)
    referer_tracking_request_add_infos[key.to_sym] = value
  end

  ###############################################

  def referer_tracking_first_request?
    @referer_tracking_first_request
  end


  def request_is_from_a_known_bot?
    bot_user_agents = /\b(GoogleBot|Mediapartners-Google|msnbot|TwengaBot|DigExt; DTS Agent|YandexImages)\b/i
    request.user_agent =~ bot_user_agents
  end

  def request_is_from_a_possible_bot?
    request.user_agent =~ /bot/i
  end

  ###############################################

  def self.included(base)
    base.class_eval do
      before_action :before_action_referer_tracking_save_to_session
      helper_method :'referer_tracking_first_request?'
      helper_method :'referer_tracking_add_info'
      helper_method :'referer_tracking_set_info'
      helper_method :'referer_tracking_get_info'
    end
  end


end

