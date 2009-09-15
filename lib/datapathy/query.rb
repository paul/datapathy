
class Datapathy::Query

  attr_reader :model, :conditions,
              :offset, :count

  def initialize(model, &blk)
    @model = model
    @conditions = []
    yield self if block_given?
  end

  def add_condition(*args)
    @conditions << Condition.new(*args)
  end

  def add(&blk)
    yield self
  end

  def add_limit(offset, count)
    @offset, @count = offset, count
  end

  def key_lookup?
    @conditions.size == 1 &&
      @conditions.first.attribute == model.key &&
      @conditions.first.operator == :eql
  end

  def key
    @conditions.first.operand
  end

  def filter_records(records)
    records = select_records(records)
    records = limit_records(records)

    records
  end

  def select_records(records)
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
    returning Condition.new(method_name) do |condition|
      @conditions << condition
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
      value = if record.is_a?(Hash)
                record[attribute.to_s]
              else
                record.send(attribute)
              end

      value.send(operator, operand)
    end
  end


end
