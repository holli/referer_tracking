module RefererTracking
  class Tracking < ActiveRecord::Base
    self.table_name = "referer_trackings"
    belongs_to :trackable, :polymorphic => true
    serialize :infos_session, Hash
    serialize :infos_request, Hash

    def first_url_combined
      cookie_first_url || session_first_url
    end
    def referer_url_combined
      cookie_referer_url || session_referer_url
    end



    def status=(new_status)
      if status != new_status
        write_attribute(:status, new_status)
        add_log_line("status #{new_status}", save_model: false)
      end
    end
    def update_status(new_status, save_model: true)
      if status != new_status
        write_attribute(:status, new_status)
        add_log_line("status #{new_status}", save_model: save_model)
      end
    end

    def add_log_line(log_line, save_model: true)
      Rails.logger.info("RefererTracking add_log_line to #{trackable_type}.#{trackable_id}: #{log_line}")

      log_line = log_line.to_s.gsub("\n", ' ')
      str = "#{Time.now.utc.to_s(:db)}: #{log_line}\n"
      self.log = log.to_s + str

      save if save_model
    end

    def get_log_lines(regexp)
      lines = log.to_s.lines.find_all{|str| str.match(regexp)}
      lines.collect{|str| [ActiveSupport::TimeZone["UTC"].parse(str), str.split(": ", 2).last.to_s.strip]}
    end

    def log=(val)
      write_attribute :log, val
    end
    private :'log='


  end
end
