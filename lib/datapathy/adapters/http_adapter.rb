require 'resourceful'
require 'yajl'
require 'active_support/core_ext/hash/keys'

module Datapathy::Adapters

  class HttpAdapter < Datapathy::Adapters::AbstractAdapter

    attr_reader :http, :services_uri

    def initialize(options = {})
      super

      @services_uri = @options[:services_uri]

      @http = Resourceful::HttpAccessor.new
      @http.logger = @options[:logger] if @options[:logger]
      @http.cache_manager = Resourceful::InMemoryCacheManager.new
      #@http.add_authenticator Resourceful::LSAuthenticator.new(@username, @password) # Add a custom authenticator
    end

    def create(collection)
      query = collection.query
      http_resource = http_resource_for(query)

      collection.each do |resource|
        record = serialize(resource)
        content_type = "application/vnd.ls.v1+json"

        begin
          response = http_resource.post(record, "Content-Type" => content_type)
          resource.key = response.header['Location']
          resource.merge!(deserialize(response)) unless response.body.blank?
        rescue Resourceful::UnsuccessfulHttpRequestError => e
          if e.http_response.code == 403
            set_errors(resource, e)
          else
            raise e
          end
        end
      end
    end

    def read(collection)
      query = collection.query
      if query.key_lookup?
        response = http.resource(query.key, default_headers).get
        Array.wrap(deserialize(response))
      else
        response = http_resource_for(query).get
        records = deserialize(response)[:items]
        records.map! { |r| r.symbolize_keys! }
        records
      end
    end

    def update(attributes, collection)
      collection.each do |resource|
        content = serialize(resource, attributes)
        content_type = content_type_for(resource)

        begin
          response = http.resource(resource.href, default_headers).put(content, "Content-Type" => content_type)
          resource.merge!(deserialize(response)) unless response.body.blank?
        rescue Resourceful::UnsuccessfulHttpRequestError => e
          if e.http_response.code == 403
            set_errors(resource, e)
          else
            raise e
          end
        end
      end
    end

    protected

    def deserialize(response)
      Yajl::Parser.parse(response.body.gsub('\/', '/')).symbolize_keys
    end

    def serialize(resource, attrs_for_update = {})
      attrs = resource.persisted_attributes.dup.merge(attrs_for_update)
      attrs.delete_if { |k,v| v.nil? }
      Yajl::Encoder.encode(attrs)
    end

    def http_resource_for(query)
      model = query.model

      url = if query.respond_to?(:location) && location = query.location
              location
            elsif model == Service
              services_uri
            else
              service = Service[model.service_type]
              service.href
            end

      raise "Could not identify a location to look for #{model}" unless url

      http.resource(url, default_headers)
    end

    def set_errors(resource, exception)
      errors =  deserialize(exception.http_response)[:errors]
      errors.each do |field, messages|
        resource.errors[field].push *messages
      end
    end


    def default_headers
      @default_headers ||= {
        :accept => 'application/vnd.ls.v1+json,application/json'
      }
    end

  end

end

