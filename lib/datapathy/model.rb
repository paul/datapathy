
module Datapathy::Model

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  attr_accessor :new_record

  def initialize(attributes = {})
    attributes.each do |name, value|
      #ivar = "@#{name.to_s.gsub(/\?$/, '')}"
      #instance_variable_set(ivar, value)
      send("#{name}=", value)
    end

    @new_record = true
  end

  def persisted_attributes
    returning({}) do |attrs|
      self.class.persisted_attributes.each do |name|
        attrs[name] = self.send(:"#{name}")
      end
    end
  end

  def save
    if new_record?
      self.class.adapter.create([self])
      @new_record = false
    else
      self.class.adapter.update(persisted_attributes, [self])
    end
  end

  def delete
    self.class.adapter.delete([self])
  end

  def key
    self.id
  end

  def model
    self.class
  end

  def ==(other)
    self.key == other.key
  end

  def new_record?
    @new_record
  end

  module ClassMethods

    def persists(*args)
      args.each do |atr|
        persisted_attributes << atr
        ivar=:"@#{atr.to_s.gsub(/\?$/,'')}"

        define_method(atr) do
          instance_variable_get(ivar)
        end

        define_method("#{atr}=") do |val|
          instance_variable_set(ivar, val)
        end
          
        # class_eval <<-EVAL
        #   def #{name}          # def id
        #     @#{name}           #   @id
        #   end                  # end
        #   alias #{name}? #{name}

        #   def #{name}=(val)    # def id=(val)
        #     @#{name} = val     #   @id = val
        #   end                  # end
        # EVAL
      end
    end

    def persisted_attributes
      @persisted_attributes ||= []
    end

    def create(attributes)
      attributes = [attributes] if attributes.is_a?(Hash)
      resources = attributes.map do |attrs|
        new(attrs)
      end
      adapter.create(resources)
      resources.each { |r| r.new_record = false }

      resources.size == 1 ? resources.first : resources
    end

    def [](key)
      query = Datapathy::Query.new(model)
      query.add_condition(self.key, :==, key)
      record = adapter.read(query)
      new(record) if record
    end

    def select(&blk)
      query = Datapathy::Query.new(model, &blk)
      Datapathy::Collection.new(query)
    end
    alias all select
    alias find_all select

    def detect(&blk) 
      self.select(&blk).first
    end
    alias first detect
    alias find detect

    def update(attributes, &blk)
      query = Datapathy::Query.new(model, &blk)

      adapter.update(attributes, query).map do |r|
        new(r)
      end
    end

    def delete(&blk)
      query = Datapathy::Query.new(model, &blk)

      adapter.delete(query)
    end

    def key
      :id
    end

    def adapter
      @adapter || Datapathy.default_adapter
    end

    def model
      self
    end

  end

end

