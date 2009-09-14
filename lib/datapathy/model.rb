
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
    returning({}) do |attrs|
      self.class.persisted_attributes.each do |name|
        attrs[name] = self.send(:"#{name}")
      end
    end
  end

  def key
    self.id
  end

  def model_name
    self.class.model_name
  end

  def ==(other)
    self.key == other.key
  end

  module ClassMethods

    def persists(*args)
      args.each do |atr|
        persisted_attributes << atr
        ivar=atr.to_s.gsub(/\?$/,'')

        define_method(atr) do  
          instance_variable_get("@#{ivar}")
        end        

        define_method("#{atr}=") do |val| 
          instance_variable_set("@#{ivar}",val)
        end
      end
    end

    def persisted_attributes
      @persisted_attributes ||= []
    end

    def create(*attributes)
      resources = attributes.map do |attrs|
        me = new(attrs)
        adapter.create([me])
        me
      end
      attributes.size == 1 ? resources.first : resources
    end

    def adapter
      @adapter || Datapathy.default_adapter
    end

    def key
      :id
    end

    def [](key)
      query = Datapathy::Query.new(self)
      query.add_condition(self.key, :eql, key)
      new(adapter.read(query))
    end

    def all
      query = Datapathy::Query.new(self)
      adapter.read(query).map do |r|
        new(r)
      end
    end

    def detect(&blk) 
      query = Datapathy::Query.new(self, &blk)

      adapter.read(query).map do |r|
        new(r)
      end.first
    end

    def model_name
      self.to_s.underscore
    end

  end

end

