# encoding: utf-8
class TimedResult

  def self.time(event, log_data = {})
    start_time = Time.now
    yield
  ensure

    time = millis_since(start_time)

    log_entries = ["event=#{event}"]
    log_entries << "request_id=#{Thread.current[:request_id]}" if Thread.current[:request_id]
    log_entries << "timing=#{time}"
    log_entries.concat(log_data.to_param.split('&'))

    HttpClient.logger.info(log_entries.join(", "))

  end

  def self.millis_since(start_time)
    (Time.now - start_time) * 1000
  end

end
