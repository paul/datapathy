require 'active_support/concern'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/slice'

require 'active_model'

require 'datapathy/query'

module Datapathy::Model
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  attr_accessor :new_record, :collection

  def initialize(attributes = {})
    @attributes = {}
    attributes.each do |name, value|
      send(:"#{name}=", value)
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

  def merge!(attributes = {})
    @attributes = @attributes || {}
    @attributes.merge!(attributes)
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

  #override the ActiveModel::Validations one, because its dumb
  def valid?
    _run_validate_callbacks if errors.empty?
    errors.empty?
  end

  module ClassMethods

    def persists(*args)
      persisted_attributes.push(*args)
      #attr_accessor *args
      args.each do |name|
        class_eval <<-CODE
          def #{name}
            @attributes[:#{name}]
          end

          def #{name}=(val)
            @attributes[:#{name}] = val
          end
        CODE
      end
    end

    def persisted_attributes
      @persisted_attributes ||= []
    end

    def new_from_attributes(attributes = {})
      m = allocate
      m.merge!(attributes = {})
      m
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
      detect(self.key => key) || raise(Datapathy::RecordNotFound, "No #{model} found with #{self.key} `#{key}`")
    end

    def select(*attrs, &blk)
      query = Datapathy::Query.new(model, *attrs, &blk)
      Datapathy::Collection.new(query)
    end
    alias all select
    alias find_all select

    def detect(*attrs, &blk)
      select(*attrs, &blk).first
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

    def method_missing(method_id, *arguments, &block)
      if match = DynamicFinderMatch.match(method_id)
        if match.finder?
          self.class_eval %{
            def self.#{method_id}(*args)
              find_attributes = Hash[[:#{match.attribute_names.join(',:')}].zip(args)]

              #{match.finder == :first ? "detect(find_attributes)" : "select(find_attributes)"}
            end
          }, __FILE__, __LINE__
          send(method_id, *arguments, &block)
        elsif match.instantiator?
          self.class_eval %{
            def self.#{method_id}(*args)
              if args[0].is_a?(Hash)
                attributes = args[0]
                find_attributes = attributes.slice(*[:#{match.attribute_names.join(',:')}])
              end

              record = detect(find_attributes)

              if record.nil?
                record = self.new(attributes)
                #{'record.save' if match.instantiator == :create}
              end

              record
            end
          }, __FILE__, __LINE__
          send(method_id, *arguments, &block)
        end
      else
        super
      end
    end

    def model_name
      ActiveModel::Name.new(self, self.to_s)
    end

  end

  class DynamicFinderMatch
    def self.match(method)
      df_match = self.new(method)
      df_match.finder ? df_match : nil
    end

    def initialize(method)
      @finder = :first
      case method.to_s
      when /^find_(all_by|last_by|by)_([_a-zA-Z]\w*)$/
        @finder = :last if $1 == 'last_by'
        @finder = :all if $1 == 'all_by'
        names = $2
      when /^find_by_([_a-zA-Z]\w*)\!$/
        @bang = true
        names = $1
      when /^find_or_(initialize|create)_by_([_a-zA-Z]\w*)$/
        @instantiator = $1 == 'initialize' ? :new : :create
        names = $2
      else
        @finder = nil
      end
      @attribute_names = names && names.split('_and_')
    end

    attr_reader :finder, :attribute_names, :instantiator

    def finder?
      !@finder.nil? && @instantiator.nil?
    end

    def instantiator?
      @finder == :first && !@instantiator.nil?
    end

    def bang?
      @bang
    end
  end
end

