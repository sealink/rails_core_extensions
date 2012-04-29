module ActiveSupport
  class TimeWithZone
    def seconds_since
      (Time.now - self).to_i
    end

    def minutes_since
      seconds_since/60
    end

    def hours_since
      minutes_since/60
    end
  end
end

