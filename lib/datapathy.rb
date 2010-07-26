
# only require the parts of activesupport we want
require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

module Datapathy

  VERSION = "0.5.0"
  def self.version
    VERSION
  end

  def self.adapters
    @adapters ||= {
      :default => Datapathy::Adapters::MemoryAdapter.new
    }
  end

  def self.default_adapter
    adapters[:default]
  end

  class RecordNotFound < StandardError
  end

end

$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
    $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'datapathy/model'
require 'datapathy/query'
require 'datapathy/collection'
require 'datapathy/adapters/abstract_adapter'
require 'datapathy/adapters/memory_adapter'

