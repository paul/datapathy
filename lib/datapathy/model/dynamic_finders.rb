
module Datapathy::Model
  module DynamicFinders
    extend ActiveSupport::Concern

    module ClassMethods

      def method_missing(method_id, *arguments, &block)
        if match = DynamicFinderMatch.match(method_id)
          if match.finder?
            self.class_eval %{
              def self.#{method_id}(*args)
                find_attributes = Hash[[:#{match.attribute_names.join(',:')}].zip(args)]

                #{match.finder == :first ? "detect(find_attributes)" : "select(find_attributes)"}
              end
            }, __FILE__, __LINE__
            send(method_id, *arguments, &block)
          elsif match.instantiator?
            self.class_eval %{
              def self.#{method_id}(*args)
                if args[0].is_a?(Hash)
                  attributes = args[0]
                  find_attributes = attributes.slice(*[:#{match.attribute_names.join(',:')}])
                end

                record = detect(find_attributes)

                if record.nil?
                  record = self.new(attributes)
                  #{'record.save' if match.instantiator == :create}
                end

                record
              end
            }, __FILE__, __LINE__
            send(method_id, *arguments, &block)
          end
        else
          super
        end
      end

      class DynamicFinderMatch

        attr_reader :finder, :attribute_names, :instantiator

        def self.match(method)
          df_match = self.new(method)
          df_match.finder ? df_match : nil
        end

        def initialize(method)
          @finder = :first
          case method.to_s
          when /^find_(all_by|last_by|by)_([_a-zA-Z]\w*)$/
            @finder = :last if $1 == 'last_by'
            @finder = :all if $1 == 'all_by'
            names = $2
          when /^find_by_([_a-zA-Z]\w*)\!$/
            @bang = true
            names = $1
          when /^find_or_(initialize|create)_by_([_a-zA-Z]\w*)$/
            @instantiator = $1 == 'initialize' ? :new : :create
            names = $2
          else
            @finder = nil
          end
          @attribute_names = names && names.split('_and_')
        end

        def finder?
          !@finder.nil? && @instantiator.nil?
        end

        def instantiator?
          @finder == :first && !@instantiator.nil?
        end

        def bang?
          @bang
        end

      end

    end

  end
end
