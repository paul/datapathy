
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

require 'datapathy/log_subscriber'
require 'datapathy/model'
require 'datapathy/query'
require 'datapathy/collection'
require 'datapathy/adapters/abstract_adapter'
require 'datapathy/adapters/memory_adapter'
require 'datapathy/adapters/http_adapter'

require 'datapathy/models/service'

require 'datapathy/railtie' if defined?(Rails)
