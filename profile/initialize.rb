
require 'rubygems'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
require 'datapathy'
class DatapathyModel
  include Datapathy::Model

  persists :id, :title, :text
end

ATTRS = {:id => 1, :title => "Foo", :text => "Bar"}

require 'ruby-prof'

# Profile the code
result = RubyProf.profile do
  100_000.times do
    DatapathyModel.new(ATTRS)
  end
end

# Print a graph profile to text
printer = RubyProf::CallTreePrinter.new(result)
File.open(File.dirname(__FILE__) + "/" + File.basename(__FILE__, ".rb") + ".calltree", "w") do |file|
  printer.print(file, 0)
end

