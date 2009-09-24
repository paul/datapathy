
require 'rubygems'
require 'rbench'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'datapathy'
class DatapathyModel
  include Datapathy::Model

  persists :id, :title, :text
end

require 'dm-core'
class DataMapperModel
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :title, String
  property :text, String
end
DataMapper.setup(:default, :adapter => :in_memory)

class PlainModel
  attr_accessor :id, :title, :text

  def initialize(attrs = {})
    #@id, @title, @text = attrs[:id], attrs[:title], attrs[:text]
    attrs.each do |key,val|
      send("#{key}=", val)
    end
  end

end

ATTRS = {:id => 1, :title => "Foo", :text => "Bar"}

RBench.run(100_000) do

  column :times
  column :plain, :title => "Ruby Class"
  column :datapathy, :title => "Datapathy"
  column :datamapper, :title => "DM #{DataMapper::VERSION}"
  #column :dpdm, :title => "DP/DM", :compare => [:datapathy, :datamapper]

  report "#new (no attributes)" do
    plain do
      PlainModel.new
    end
    datapathy do
      DataMapperModel.new
    end
    datamapper do
      DataMapperModel.new
    end
  end

  report "#new (3 attributes)" do
    plain do
      PlainModel.new ATTRS
    end
    datapathy do
      DataMapperModel.new ATTRS
    end
    datamapper do
      DataMapperModel.new ATTRS
    end
  end


end
