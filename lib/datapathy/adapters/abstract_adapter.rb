module Datapathy::Adapters

  class AbstractAdapter

    def initialize(options = {})
      @options = options

    end

    def create(resources)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def read(query)
      raise NotImplementedError, "#{self.class}#read not implemented"
    end

    def update(attributes, collection)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def delete(collection)
      raise NotImplementedError, "#{self.class}#delete not implemented"
    end

  end

end

