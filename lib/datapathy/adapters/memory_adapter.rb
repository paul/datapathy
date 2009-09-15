require 'active_support/core_ext/hash/keys'

module Datapathy::Adapters

  class MemoryAdapter < AbstractAdapter

    def initialize(options = {})
      super

      @store = {}
    end

    def create(resources)
      resources.each do |resource|
        records_for(resource)[resource.key] = resource.persisted_attributes.stringify_keys
      end
    end

    def read(query)
      if query.key_lookup?
        records_for(query)[query.key]
      else
        query.filter_records(records_for(query).values)
      end
    end

    def update(attributes, query_or_collection)
      if query_or_collection.is_a?(Datapathy::Query)
        query = query_or_collection
        model = query.model
        key   = model.key
        attributes = attributes.stringify_keys
        read(query).each do |record|
          record.merge!(attributes)
          records_for(query)[record[key]] = record
        end
      else
        collection = query_or_collection
        collection.each do |resource|
          records_for(resource)[resource.key] = resource.persisted_attributes.stringify_keys
        end
      end
    end

    def records_for(resource_or_query)
      datastore[resource_or_query.model]
    end

    def datastore
      @datastore ||= Hash.new { |h,k| h[k] = {} }
    end

    def clear!
      @datastore = nil
    end

  end

end

