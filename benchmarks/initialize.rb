
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

require 'active_record'
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "benchmark.db"
)
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_record_models")
ActiveRecord::Base.connection.execute("CREATE TABLE active_record_models (id INTEGER UNIQUE, title STRING, text STRING)")
class ActiveRecordModel < ActiveRecord::Base
end
# Have AR scan the table before the benchmark
ActiveRecordModel.new

class PlainModel
  attr_accessor :id, :title, :text

  def initialize(attrs = {})
    @id, @title, @text = attrs[:id], attrs[:title], attrs[:text]
  end

end

class HashModel
  def initialize(attributes = {})
    attrs = {}
    attrs.merge!(attributes)
  end
end

ATTRS = {:id => 1, :title => "Foo", :text => "Bar"}

RBench.run(100_000) do

  column :times
  column :plain, :title => "Ruby Class"
  column :hash,  :title => "Hash Model"
  column :datapathy, :title => "Datapathy"
  column :datamapper, :title => "DM #{DataMapper::VERSION}"
  column :ar,         :title => "AR 3.0.pre"

  report "#new (no attributes)" do
    plain do
      PlainModel.new
    end
    hash do
      HashModel.new
    end
    datapathy do
      DatapathyModel.new
    end
    datamapper do
      DataMapperModel.new
    end
    ar do
      ActiveRecordModel.new
    end
  end

  report "#new (3 attributes)" do
    plain do
      PlainModel.new ATTRS
    end
    hash do
      HashModel.new ATTRS
    end
    datapathy do
      DatapathyModel.new.merge!(ATTRS)
    end
    datamapper do
      DataMapperModel.new ATTRS
    end
    ar do
      ActiveRecordModel.new ATTRS
    end
  end


end
