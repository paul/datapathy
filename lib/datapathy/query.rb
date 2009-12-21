require 'active_support/basic_object'
require 'active_support/core_ext/module/delegation'

class Datapathy::Query

  attr_reader :model, :conditions,
              :offset, :count

  def initialize(model, attrs = {}, &blk)
    @model = model
    @conditions = ConditionSet.new
    @blocks = []
    attrs.each do |k,v|
      add { |q| q.send(k) == v }
    end
    add(&blk) if block_given?
  end

  def add(&blk)
    @blocks << blk
    yield @conditions
  end

  def key_lookup?
    @conditions.size == 1 &&
      @conditions.first.operation == model.key &&
      @conditions.first.then.operation == :==
  end

  def key
    @conditions.first.then.arguments.first
  end

  def perform
    initialize_and_filter(model.adapter.read(self))
  end

  def initialize_and_filter(records)
    filter(initialize_resources(records))
  end

  def initialize_resources(records)
    records.map { |record|
      resource = model.new(record)
      resource.new_record = false
      resource
    }
  end

  def filter(resources)
    resources = match_resources(resources)
    resources = order_resources(resources)
    resources = limit_resources(resources)

    resources
  end

  def match_resources(resources)
    resources.select do |record|
      @blocks.all? do |block|
        block.call(record)
      end
    end
  end

  def order_resources(resources)
    resources
  end

  def limit_resources(resources)
    return resources unless @offset || @count
    resources.slice(@offset || 0, @count)
  end

  def limit(count, offset = 0)
    @count, @offset = count, offset
  end

  class ConditionSet < ActiveSupport::BasicObject

    delegate :size, :first, :to => :@conditions

    def initialize
      @conditions = []
    end

    def method_missing(method_name, *args, &blk)
      condition = Condition.new(method_name, *args, &blk)
      @conditions << condition
      condition
    end


    def inspect
      @conditions.inspect
    end
  end

  class Condition < ActiveSupport::BasicObject

    attr_reader :then
    attr_accessor :operation, :arguments, :block

    def initialize(operation, *arguments, &block)
      @operation = operation
      @arguments = arguments unless arguments.empty?
      @block = block if block
    end

    def method_missing(method_name, *args, &blk)
      @then = Condition.new(method_name, *args, &blk)
    end

    def respond_to?(arg)
      false
    end

    def inspect
      "#{operation}(#{@arguments.inspect unless @arguments.nil?})#{".#{@then.inspect}" if @then}"
    end

  end

end
