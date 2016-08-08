require 'curb'
require 'typhoeus'
require 'uri'
require 'oj'

class ConnectorService
  class << self
    def connect_to_dataset_service(dataset_id, status)
      status = case status
               when 'saved'   then 1
               when 'deleted' then 3
               else 2
               end

      params = { dataset: { dataset_attributes: { status: status } } }
      url    = URI.decode("#{ServiceSetting.gateway_url}/datasets/#{dataset_id}")

      @c = Curl::Easy.http_put(URI.escape(url), Oj.dump(params)) do |curl|
        curl.headers['Accept']         = 'application/json'
        curl.headers['Content-Type']   = 'application/json'
        curl.headers['authentication'] = ServiceSetting.auth_token if ServiceSetting.auth_token.present?
      end
      @c.perform
    end

    def connect_to_provider(connector_url, data_path)
      url  = URI.decode(connector_url)

      headers = {}
      headers['Accept']       = 'application/json'
      headers['Content-Type'] = 'application/json'

      hydra    = Typhoeus::Hydra.new max_concurrency: 100
      @request = ::Typhoeus::Request.new(URI.escape(url), method: :get, headers: headers, followlocation: true)

      @request.on_complete do |response|
        if response.success?
          # cool
        elsif response.timed_out?
          'got a time out'
        elsif response.code.zero?
          response.return_message
        else
          'HTTP request failed: ' + response.code.to_s
        end
      end

      hydra.queue @request
      hydra.run

      Oj.load(@request.response.body.force_encoding(Encoding::UTF_8))[data_path] || Oj.load(@request.response.body.force_encoding(Encoding::UTF_8))
    end
  end
end
