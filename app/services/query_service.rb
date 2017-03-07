# frozen_string_literal: true
require 'typhoeus'
require 'uri'
require 'oj'

module QueryService
  class << self
    def connect_to_query_service(sql_params, geostore=nil)
      url  = URI.decode("#{Service::SERVICE_URL}/convert/sql2FS?sql=#{sql_params}")
      url += "&geostore=#{geostore}" if geostore.present?

      headers = {}
      headers['Accept']         = 'application/json'
      headers['Content-Type']   = 'application/json'
      headers['authentication'] = Service::SERVICE_TOKEN
      
      hydra    = Typhoeus::Hydra.new max_concurrency: 100
      @request = Typhoeus::Request.new(URI.escape(url), method: :get, headers: headers, followlocation: true)
      
      
      @request.on_complete do |response|
        Rails.logger.info "Response: #{response.options}"
        Rails.logger.info "Response code: #{response.code}"
        
        if response.success?
          @data = Oj.load(@request.response.body.force_encoding(Encoding::UTF_8))['data']['attributes']['query'] || Oj.load(@request.response.body.force_encoding(Encoding::UTF_8))
        elsif response.timed_out?
          @data = 'got a time out'
        elsif response.code.zero?
          @data = response.return_message
        elsif response.code == 400
          @data = {"errors" => "Bad query"}
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

