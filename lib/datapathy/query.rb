
class Datapathy::Query

  attr_reader :model, :conditions,
              :offset, :count

  def initialize(model, &blk)
    @model = model
    @conditions = []
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
      @conditions.all? do |condition|
        condition.matches?(record)
      end
    end
  end

  def limit_records(records)
    return records unless @offset || @count
    records.slice(@offset || 0, @count)
  end

  def method_missing(method_name, *args)
    #if model.instance_methods.include?(method_name)
    if model.respond_to?(method_name)
      returning Condition.new(method_name) do |condition|
        @conditions << condition
      end
    else 
      super
    end
  end

  class Condition
    attr_reader :attribute, :operator, :operand

    def initialize(attribute = nil, operator = nil, operand = nil)
      @attribute, @operator, @operand = attribute, operator, operand
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

    def matches?(record)
      value = record[attribute]
      value.send(operator, operand)
    end
  end


end
