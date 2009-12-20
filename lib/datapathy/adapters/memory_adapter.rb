require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/array/wrap'

module Datapathy::Adapters

  class MemoryAdapter < AbstractAdapter

    def initialize(options = {})
      super
    end

    def create(resources)
      resources.each do |resource|
        if records_for(resource).has_key?(resource.key)
          resource.errors[resource.model.key] << "Must be unique"
        else
          records_for(resource)[resource.key] = resource.persisted_attributes
        end
      end
    end

    def read(query)
      if query.key_lookup?
        Array.wrap(records_for(query)[query.key])
      else
        records_for(query).values
      end
    end

    def update(attributes, query_or_collection)
      if query_or_collection.is_a?(Datapathy::Query)
        query = query_or_collection
        key   = query.model.key

        read(query).each do |record|
          record.merge!(attributes)
          records_for(query)[record[key]] = record
        end
      else
        collection = query_or_collection

        collection.each do |resource|
          records_for(resource)[resource.key] = resource.persisted_attributes
        end
      end
    end

    def delete(query_or_collection)
      if query_or_collection.is_a?(Datapathy::Query)
        query = query_or_collection
        key = query.model.key

        read(query).each do |record|
          records_for(query).delete(record[key])
        end
      else
        collection = query_or_collection

        collection.each do |resource|
          records_for(resource).delete(resource.key)
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

