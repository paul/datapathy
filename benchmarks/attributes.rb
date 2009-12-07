
require 'rubygems'
require 'rbench'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'datapathy'
class DatapathyModel
  include Datapathy::Model

  persists :a, :b, :c
end

require 'fattr'
class MyFattr
  fattr :a, :b, :c

  def initialize(args = {})
    args.each do |k,v|
      send(k, v)
    end
  end
end

class AttrAccessor
  attr_accessor :a, :b, :c

  def initialize(args = {})
    args.each do |k,v|
      send(:"#{k}=", v)
    end
  end
end

require 'ostruct'
class MyStruct < OpenStruct; end

class MyHash < Hash; end

ATTRS = {:a => 1, :b => 2, :c => 3}

RBench.run(100_000) do

  column :datapathy
  column :fattr
  column :accessor
  column :ostruct
  column :hash
  column :object

  report "empty args" do
    datapathy { DatapathyModel.new }
    fattr { MyFattr.new }
    accessor  { AttrAccessor.new }
    ostruct { MyStruct.new }
    hash { Hash.new }
    object { Object.new }
  end

  report "hash args" do
    datapathy { DatapathyModel.new(ATTRS) }
    fattr { MyFattr.new(ATTRS) }
    accessor { AttrAccessor.new(ATTRS) }
    ostruct { MyStruct.new(ATTRS) }
    hash { Hash.new(ATTRS) }
  end
end

