
require 'uuidtools'

module Datapathy

  def self.default_adapter
    @adapter ||= Datapathy::Adapters::MemoryAdapter.new
  end

end


require File.join(File.dirname(__FILE__), 'datapathy/model')
require File.join(File.dirname(__FILE__), 'datapathy/adapters/memory_adapter')

