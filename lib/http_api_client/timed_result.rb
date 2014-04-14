# encoding: utf-8
module HttpApiClient
  class TimedResult

    def self.time(event, log_data = {})
      start_time = Time.now
      yield
    ensure

      time = millis_since(start_time)

      log_entries = ["event_name=#{event}"]
      log_entries << "request_id=#{Thread.current[:request_id]}" if Thread.current[:request_id]
      log_entries << "timing=#{time}"
      log_entries.concat(as_log_entries(log_data))

      HttpApiClient.logger.info(log_entries.join(", "))

    end

    def self.millis_since(start_time)
      (Time.now - start_time) * 1000
    end

    def self.as_log_entries(hash)
      hash.inject [] do |result, entry|
        result << "#{entry[0]}=#{entry[1]}"
      end
    end

  end
end