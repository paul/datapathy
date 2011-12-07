
# only require the parts of activesupport we want
require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

module Datapathy
  extend self

  attr_accessor :services_uri

  VERSION = "0.6.0"
  def version
    VERSION
  end

  def adapter
    @adapter ||= Datapathy::Adapters::HttpAdapter.new(:services_uri => services_uri)
  end

  def configure
    block_given? ? yield(self) : self
  end

  class RecordNotFound < StandardError
  end

end

require 'datapathy/log_subscriber'
require 'datapathy/model'
require 'datapathy/query'
require 'datapathy/collection'
require 'datapathy/adapters/http_adapter'

require 'datapathy/models/service'

require 'datapathy/railtie' if defined?(Rails)
