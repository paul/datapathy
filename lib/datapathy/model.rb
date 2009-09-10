
module Datapathy::Model

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      self.send(:"#{name}=", value)
    end
  end

  def persisted_attributes
    persisted_attributes = {}
    self.class.persisted_attributes.each do |name|
      persisted_attributes[name] = self.send(:"#{name}")
    end
    persisted_attributes
  end

  def key
    self.id
  end

  module ClassMethods

    def persists(*args)
      args.each do |atr|
        persisted_attributes << atr

        define_method(atr) do  
          instance_variable_get("@#{atr}")
        end        

        define_method("#{atr}=") do |val| 
          instance_variable_set("@#{atr}",val)
        end
      end
    end

    def persisted_attributes
      @persisted_attributes ||= []
    end

    def create(attributes)
      me = new(attributes)
      adapter.create([me])
      me
    end

    def adapter
      @adapter || Datapathy.default_adapter
    end

    def [](key)
      new(adapter.read(key))
    end


  end

end

