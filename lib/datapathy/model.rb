require 'active_support/concern'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/slice'

require 'active_model'

require 'datapathy/query'

require 'datapathy/model/crud'
require 'datapathy/model/dynamic_finders'

module Datapathy::Model
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  include Datapathy::Model::Crud
  include Datapathy::Model::DynamicFinders

  attr_accessor :new_record

  def initialize(attributes = {})
    @attributes = {}
    attributes.each do |name, value|
      send(:"#{name}=", value)
    end
    @new_record = true
  end

  def persisted_attributes
    @attributes
  end

  def merge!(attributes = {})
    @attributes = @attributes || {}
    @attributes.merge!(attributes)
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

  #override the ActiveModel::Validations one, because its dumb
  def valid?
    _run_validate_callbacks if errors.empty?
    errors.empty?
  end

  module ClassMethods

    def new(*attributes)
      attributes = [{}] if attributes.empty?
      resources = attributes.map do |attrs|
        super(attrs)
      end

      collection = Datapathy::Collection.new(*resources)
      collection.size == 1 ? collection.first : collection
    end

    def persists(*args)
      persisted_attributes.push(*args)
      args.each do |name|
        name = name.to_s.gsub(/\?\Z/, '')
        define_getter_method(name)
        define_setter_method(name)
      end
    end

    def define_getter_method(name)
      class_eval <<-CODE
        def #{name}
          @attributes[:#{name}]
        end
        alias #{name}? #{name}
      CODE
    end

    def define_setter_method(name)
      class_eval <<-CODE
        def #{name}=(val)
          @attributes[:#{name}] = val
        end
      CODE
    end

    def persisted_attributes
      @persisted_attributes ||= []
    end

    def new_from_attributes(attributes = {})
      m = allocate
      m.merge!(attributes = {})
      m.new_record = false
      m
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

    def model_name
      ActiveModel::Name.new(self)
    end

  end

end

