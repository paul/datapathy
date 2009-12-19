
class Datapathy::Query

  attr_reader :model, :conditions,
              :offset, :count

  def initialize(model, attrs = {}, &blk)
    @model = model
    @conditions = []
    attrs.each do |k,v|
      add_condition(model, k, :==, v)
    end
    add(&blk) if block_given?
  end

  def add_condition(*args)
    @conditions << Condition.new(*args)
  end

  def add(&blk)
    begin
      yield self
    rescue NoMethodError => e
      raise NoMethodError, "no attribute `#{e.name}' on #{model} to be queried"
    end
  end

  def add_limit(offset, count)
    @offset, @count = offset, count
  end

  def key_lookup?
    @conditions.size == 1 &&
      @conditions.first.attribute == model.key &&
      @conditions.first.operator == :==
  end

  def key
    @conditions.first.operand
  end

  def perform
    resources = model.adapter.read(self).map do |r|
      record = model.new(r)
      record.new_record = false
      record
    end
    resources.select do |r|
      method_conditions.all? do |c|
        c.matches?(r)
      end
    end
  end

  # Used in adapters to filter hashes of records.
  # The keys of the hashes must be symbols representing
  # attribute names!
  def filter_records(records)
    records = match_records(records)
    records = limit_records(records)

    records
  end

  def match_records(records)
    records.select do |record|
      attribute_conditions.all? do |condition|
        condition.matches?(record)
      end
    end
  end

  def limit_records(records)
    return records unless @offset || @count
    records.slice(@offset || 0, @count)
  end

  def method_missing(method_name, *args)
    condition = Condition.new(model, method_name, *args)
    @conditions << condition
    condition
  end

  def attribute_conditions
    @conditions.select { |c| c.matches_attribute? }
  end

  def method_conditions
    @conditions.select { |c| !c.matches_attribute? }
  end

  class Condition
    attr_reader :attribute, :operator, :operand

    def initialize(model, attribute, *args)
      @attribute = attribute
      if model.persisted_attributes.include?(attribute)
        @matches_attribute = true
        @operator, @operand = *args
      else
        @matches_attribute = false
        @args = args
        @operator, @operand = :==, true
      end
    end

    [ :==, :===, :eql?, :equal?, :=~, :<=>, :<=, :<, :>, :>= ].each do |op|
      define_method(op) do |val|
        @operator = op
        @operand = val
      end
    end

    def contains?(val)
      @operator = :contains
      @operand = val
      self
    end

    def nil?
      @operator = :==
      @operand = nil
    end

    def matches_attribute?
      @matches_attribute
    end

    def matches?(record)
      if matches_attribute?
        value = record[attribute]
      else
        value = record.send(attribute, *@args)
      end
      value.send(operator, operand)
    end
  end


end
