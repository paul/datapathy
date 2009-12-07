
require 'rubygems'
require 'rbench'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'datapathy'
class DatapathyModel
  include Datapathy::Model

  persists :id, :title, :text
end

HASH = {
  :id => 1,
  :title => "test",
  :text => "Lorem Ipsum"
}


RBench.run(500_000) do

  column :hash
  column :model

  report "init" do
    hash { HASH }
    model { DatapathyModel.new(HASH) }
  end

  report "search" do
    hash { [HASH].select { |h| h[:title] == "test" } }
    model { [DatapathyModel.new(HASH)].select { |m| m.title == "test" } }
  end
end
