
require 'uuidtools'

# only require the parts of activesupport we want
require 'active_support/core_ext/object/returning'
require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

module Datapathy

  VERSION = "0.1.0"
  def self.version
    VERSION
  end

  def self.default_adapter
    @adapter ||= Datapathy::Adapters::MemoryAdapter.new
  end

  def self.default_adapter=(adapter)
    @adapter = adapter
  end

end

$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
    $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'datapathy/model'
require 'datapathy/query'
require 'datapathy/collection'
require 'datapathy/adapters/abstract_adapter'
require 'datapathy/adapters/memory_adapter'

