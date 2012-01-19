class RefererTracking::Sweeper < ActionController::Caching::Sweeper
  #observe ::Dummy::User

  #def self.observe_add
  #
  #end

  def after_save(record)
    ses = session["referer_tracking"] || {}

    ref_mod = RefererTracking::RefererTracking.new(
        :trackable_id => record.id, :trackable_type => record.class.to_s)

    ses.each_pair do |key, value|
      ref_mod[key] = value if ref_mod.has_attribute?(key)
    end

    ref_mod[:user_agent] = request.env['HTTP_USER_AGENT']
    ref_mod.save
  end
end

