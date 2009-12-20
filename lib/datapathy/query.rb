require 'active_support/basic_object'

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
    @conditions.first.operation if key_lookup?
  end

  def perform
    resources = model.adapter.read(self).map do |record|
      record = model.new(record)
      record.new_record = false
      record
    end
    filter_records(resources)
  end

  def filter_records(records)
    records = match_records(records)
    records = order_records(records)
    records = limit_records(records)

    records
  end

  def match_records(records)
    records.select do |record|
      @blocks.all? do |block|
        block.call(record)
      end
    end
  end

  def order_records(records)
    records
  end

  def limit_records(records)
    return records unless @offset || @count
    records.slice(@offset || 0, @count)
  end

  def limit(count, offset = 0)
    @count, @offset = count, offset
  end

  class ConditionSet < Array
    def method_missing(method_name, *args, &blk)
      condition = Condition.new(method_name, *args, &blk)
      self << condition
      condition
    end
  end

  class Condition
    undef_method :==
    undef_method :equal?

    attr_reader :then
    attr_accessor :operation, :arguments, :block

    def initialize(operation, *arguments, &block)
      @operation = operation
      @arguments = arguments unless arguments.empty?
      @block = block if block
    end

    def method_missing(method_name, *args, &blk)
      @then = self.class.new(method_name, *args, &blk)
    end

  end

end
