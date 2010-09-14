require 'active_support/log_subscriber'
require 'active_support/notifications'

module Datapathy
  class LogSubscriber < ActiveSupport::LogSubscriber

    def self.runtime=(value)
      Thread.current["datapathy_query_runtime"] = value
    end

    def self.runtime
      Thread.current["datapathy_query_runtime"] ||= 0
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def query(event)
      self.class.runtime += event.duration
      debug("Datapathy Query: %s (%.1fms) %s" % [event.payload[:name], event.duration, event.payload[:query]])
    end

  end
end

Datapathy::LogSubscriber.attach_to :datapathy
