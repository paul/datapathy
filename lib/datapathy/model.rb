require 'active_support/core_ext/class/inheritable_attributes'
require 'active_model/validations'

require 'datapathy/query'

module Datapathy::Model

  def self.included(klass)
    klass.extend(ClassMethods)
    klass.send(:include, ActiveModel::Validations)
  end

  attr_accessor :new_record, :collection

  def initialize(attributes = {})
    attributes.each do |name, value|
      ivar = "@#{name.to_s.gsub(/\?$/, '')}"
      instance_variable_set(ivar, value)
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

  def merge!(attributes)
    attributes.each do |name, value|
      ivar = "@#{name.to_s.gsub(/\?$/, '')}"
      instance_variable_set(ivar, value)
    end
  end

  def save
    if new_record?
      create()
    else
      update()
    end
  end

  def create
    adapter.create(collection)
    @new_record = false
  end

  def update
    adapter.update(persisted_attributes, collection)
  end

  def delete
    adapter.delete([self])
  end

  def key
    send(self.class.key)
  end

  def key=(value)
    send(:"#{self.class.key}=", value)
  end

  def model
    self.class
  end

  def ==(other)
    self.key == (other && other.key)
  end

  def new_record?
    @new_record
  end

  def adapter
    self.class.adapter
  end

  def collection
    return @collection if @collection
    query = Datapathy::Query.new(self.class)
    @collection = Datapathy::Collection.new(query, [self])
  end

  def query
    collection.query
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

