require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/array/wrap'

module Datapathy::Adapters

  class MemoryAdapter < AbstractAdapter

    def initialize(options = {})
      super
    end

    def create(collection)
      collection.map do |resource|
        if records_for(resource).has_key?(resource.key)
          resource.errors[resource.model.key] << "Must be unique"
          resource
        else
          records_for(resource)[resource.key] = resource.persisted_attributes
        end
      end
    end

    def read(collection)
      query = collection.query
      if query.key_lookup?
        Array.wrap(records_for(query)[query.key])
      else
        records_for(query).values
      end
    end

    def update(attributes, collection)
      if collection.loaded?
        collection.map do |resource|
          records_for(resource)[resource.key] = resource.persisted_attributes.merge(attributes)
        end
      else
        query = collection.query

        query.initialize_and_filter(read(collection)).map do |resource|
          record = resource.persisted_attributes.merge!(attributes)
          records_for(query)[resource.key] = record
        end
      end
    end

    def delete(collection)
      if collection.loaded?
        collection.map do |resource|
          records_for(resource).delete(resource.key)
        end
      else
        query = collection.query
        key = query.model.key

        query.initialize_and_filter(read(collection)).map do |record|
          records_for(query).delete(record.key)
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

