module Datapathy::Adapters

  class MemoryAdapter

    def initialize
      @store = {}
    end

    def create(resources)
      resources.each do |resource|
        @store[resource.key] = resource.persisted_attributes
      end
    end

    def read(key)
      @store[key]
    end

  end

end

