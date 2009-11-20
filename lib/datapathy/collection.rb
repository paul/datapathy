class Datapathy::Collection

  attr_reader :query, :model, :adapter

  def initialize(query, elements = nil)
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

  def detect(&blk)
    select(&blk).first
  end
  alias find detect

  def select(&blk)
    query.add(&blk)
    self
  end
  alias find_all select

  def loaded?
    @elements
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
    @elements = query.perform
  end

end
