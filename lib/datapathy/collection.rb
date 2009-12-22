class Datapathy::Collection

  attr_reader :query, :model, :adapter

  # Collection.new(query)
  # Collection.new(model, ...)
  # Collection.new(Model, record, ...)
  def initialize(*elements)
    if elements.first.is_a?(Datapathy::Query)
      query = elements.shift
    elsif elements.first.is_a?(Datapathy::Model)
      query = Datapathy::Query.new(elements.first.model)
    elsif elements.first.ancestors.include?(Datapathy::Model)
      query = Datapathy::Query.new(elements.shift)
      elements = Array.wrap(query.model.new(*elements))
    else
      raise "First element must be a query, model, or Model class"
    end

    @query, @model, @adapter = query, query.model, query.model.adapter
    @elements = elements
  end

  def new(*attributes)
    collection = self.class.new(self.model, *attributes)
    collection.size == 1 ? collection.first : collection
  end

  def create(*attributes)
    if attributes.empty?
      adapter.create(self)
      each { |r| r.new_record = false }

      size == 1 ? first : self
    else
      self.class.new(model, *attributes).create
    end
  end

  def detect(*attrs, &blk)
    slice(0, 1)
    select(*attrs, &blk)
    to_a.first
  end
  alias find detect
  alias first detect

  def select(*attrs, &blk)
    query.add(*attrs, &blk)
    self
  end
  alias find_all select

  def slice(index_or_start_or_range, length = nil)
    if index_or_start_or_range.is_a?(Range)
      range = index_or_start_or_range
      count, offset = (range.last - range.first), range.first
    elsif length
      start = index_or_start_or_range
      count, offset = length, start
    else
      count, offset = 1, index_or_start_or_range
    end

    query.limit(count, offset)
  end

  def update(attributes = {}, &blk)
    query.add(&blk)
    @elements = query.initialize_resources(adapter.update(attributes, self))
  end

  def delete(&blk)
    query.add(&blk)
    @elements = query.initialize_resources(adapter.delete(self))
  end

  def loaded?
    !@elements.empty?
  end

  # Since @elements is an array, pretty much every array method should trigger
  # a load. The exceptions are the ones defined above.
  TRIGGER_METHODS = (Array.instance_methods - self.instance_methods).freeze
  TRIGGER_METHODS.each do |meth|
    class_eval <<-EVAL, __FILE__, __LINE__
      def #{meth}(*a, &b)
        self.load! unless loaded?
        @elements.#{meth}(*a, &b)
      end
    EVAL
  end

  def to_a
    self.load! unless loaded?
    @elements
  end

  def load!
    @elements = query.initialize_and_filter(adapter.read(self))
  end

end
