
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

require File.join(File.dirname(__FILE__), 'datapathy/model')
require File.join(File.dirname(__FILE__), 'datapathy/query')
require File.join(File.dirname(__FILE__), 'datapathy/adapters/abstract_adapter')
require File.join(File.dirname(__FILE__), 'datapathy/adapters/memory_adapter')

