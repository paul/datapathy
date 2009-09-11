module Datapathy::Adapters

  class MemoryAdapter < AbstractAdapter

    def initialize(options = {})
      super

      @store = {}
    end

    def create(resources)
      resources.each do |resource|
        records_for(resource)[resource.key] = resource.persisted_attributes
      end
    end

    def read(query)
      if query.key_lookup?
        records_for(query.model)[query.key]
      else
        query.filter_records(records_for(query.model).values)
      end
    end

    protected

    def records_for(resource)
      @store[resource.model_name] ||= {}
    end

  end

end

