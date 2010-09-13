require 'rails'
require 'active_model/railtie'

require 'action_controller/railtie'

module Datapathy
  class Railtie < Rails::Railtie

    initializer "datapathy.log_runtime" do |app|
      ActiveSupport.on_load(:action_controller) do
        include Datapathy::Railties::ControllerRuntime
      end
    end
  end

  require 'active_support/core_ext/module/attr_internal'
  module Railties
    module ControllerRuntime
      extend ActiveSupport::Concern

      attr_internal :query_runtime

      def cleanup_view_runtime
        runtime_before_render = Datapathy::LogSubscriber.reset_runtime
        runtime = super
        runtime_after_render = Datapathy::LogSubscriber.reset_runtime
        self.query_runtime = runtime_before_render + runtime_after_render
        runtime - runtime_after_render
      end

      def append_info_to_payload(payload)
        super
        payload[:query_runtime] = self.query_runtime
      end

      module ClassMethods
        def log_process_action(payload)
          messages, query_runtime = super, payload[:query_runtime]
          messages << ("Datapathy Query: %.1fms" % query_runtime.to_f) if query_runtime
          messages
        end
      end

    end
  end

end

