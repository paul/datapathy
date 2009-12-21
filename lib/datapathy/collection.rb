class Datapathy::Collection

  attr_reader :query, :model, :adapter

  def initialize(*elements)
    raise "Collection must be initialized with a Query or Model(s)." if elements.empty?
    if elements.first.is_a?(Datapathy::Query)
      query = elements.shift
    else
      query = Datapathy::Query.new(elements.first.model)
    end

    @query, @model, @adapter = query, query.model, query.model.adapter
    @elements = elements.map { |e| e.collection = self; e } unless elements.nil?
  end

  def new(attributes = {})
    attributes = [attributes] if attributes.is_a?(Hash)
    resources = attributes.map do |attrs|
      model.new(attrs)
    end

    collection = self.class.new(query, resources)
    resources.size == 1 ? resources.first : resources
  end

  def create(attributes = {})
    attributes = [attributes] if attributes.is_a?(Hash)
    resources = attributes.map do |attrs|
      model.new(attrs)
    end

    collection = self.class.new(query, resources)
    adapter.create(collection)
    resources.each { |r| r.new_record = false }

    resources.size == 1 ? resources.first : resources
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
