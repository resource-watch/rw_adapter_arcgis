# frozen_string_literal: true
require 'curb'
require 'typhoeus'
require 'uri'
require 'oj'

module ConnectorService
  class << self
    def connect_to_dataset_service(dataset_id, status)
      status = case status
               when 'saved'   then 1
               when 'deleted' then 3
               else 2
               end

      params = { dataset: { status: status } }
      url    = URI.decode("#{Service::SERVICE_URL}/datasets/#{dataset_id}")

      @c = Curl::Easy.http_put(URI.escape(url), Oj.dump(params)) do |curl|
        curl.headers['Accept']         = 'application/json'
        curl.headers['Content-Type']   = 'application/json'
        curl.headers['authentication'] = Service::SERVICE_TOKEN
      end
      @c.perform
    end

    def connect_to_provider(connector_url, data_path)
      url  = URI.decode(connector_url)

      headers = {}
      headers['Accept']       = 'application/json'
      headers['Content-Type'] = 'application/json'

      hydra    = Typhoeus::Hydra.new max_concurrency: 100
      @request = Typhoeus::Request.new(URI.escape(url), method: :get, headers: headers, followlocation: true)

      @request.on_complete do |response|
        if response.success?
          @data = Oj.load(response.body.force_encoding(Encoding::UTF_8))[data_path] || Oj.load(response.body.force_encoding(Encoding::UTF_8))
        elsif response.timed_out?
          @data = 'got a time out'
        elsif response.code.zero?
          @data = response.return_message
        else
          @data = Oj.load(response.body)
        end
      end
      hydra.queue @request
      hydra.run
      @data
    end
  end
end
