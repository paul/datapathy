
module Matchers

  class HaveErrorsMatcher

    def initialize(attribute)
      @attribute = attribute
    end

    def matches?(resource)
      @resource = resource
      !@resource.errors[@attribute].empty?
    end

    def failure_message_for_should
      "Expected resource to have errors on #{@attribute}. Errors: #{@resource.errors.inspect}"
    end

    def failure_message_for_should_not
      "Expected resource to not have errors on #{@attribute}. Errors: #{@resource.errors.inspect}"
    end

  end

  def have_errors_on(attribute)
    HaveErrorsMatcher.new(attribute)
  end

end

