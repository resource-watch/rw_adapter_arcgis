# frozen_string_literal: true
require 'curb'
require 'typhoeus'
require 'uri'
require 'oj'
require 'yajl'

module ConnectorService
  FLUSH_EVERY = 500

  class << self
    def connect_to_dataset_service(dataset_id, status)
      status = case status
               when 'saved'   then 1
               when 'deleted' then 3
               else 2
               end

      params = { dataset: { status: status } }
      url    = URI.decode("#{Service::SERVICE_URL}/dataset/#{dataset_id}")

      @c = Curl::Easy.http_put(URI.escape(url), Oj.dump(params)) do |curl|
        curl.headers['Accept']         = 'application/json'
        curl.headers['Content-Type']   = 'application/json'
        curl.headers['authentication'] = Service::SERVICE_TOKEN
      end
      @c.perform
    end

    def connect_to_provider(connector_url, data_path=nil, attr_path=nil)
      puts "Connector URL: #{connector_url}"
      url  = URI.decode(connector_url)
      puts "Decoded URL: #{url}"
      headers = {}
      headers['Accept']       = 'application/x-www-form-urlencoded'
      headers['Content-Type'] = 'application/x-www-form-urlencoded'

      query_url   = url.split('?')[0]
      puts "Query URL: #{query_url}"
      form_params = url.split('?')[1]
      puts "Query params: #{form_params}"
      form_params = CGI::parse(URI.decode(form_params)).symbolize_keys!
      form_params = flatten_hash(form_params)

      Typhoeus::Config.memoize = true
      hydra    = Typhoeus::Hydra.new max_concurrency: 100
      @request = Typhoeus::Request.new(URI.escape(query_url), method: :post, headers: headers, body: form_params)


      count = form_params[:returnCountOnly].present?

      @request.on_complete do |response|
        if response.success?
          if data_path.present? && count.blank?
            @data = response_processor(data_path, response)
          elsif attr_path.present? || count.present?
            parser = Yajl::Parser.new
            @data  = parser.parse(response.body)[attr_path] || Oj.load(response.body.force_encoding(Encoding::UTF_8))
          else
            parser = Yajl::Parser.new
            @data  = parser.parse(response.body)
          end
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

    def response_processor(data_path, response)
      parser = YAJI::Parser.new(response.body)
      i      = 0
      Enumerator.new do |set|
        parser.each("/#{data_path}/") do |obj|
          set << obj.symbolize_keys!
          i = i + 1
          if (i % FLUSH_EVERY).zero?
            GC.start(full_mark: false, immediate_sweep: false)
          end
        end
      end
    end

    def flatten_hash(param, prefix=nil)
      param.each_pair.reduce({}) do |a, (k, v)|
        v.is_a?(Hash) ? a.merge(flatten_hash(v, "#{prefix}#{k}.")) : a.merge("#{prefix}#{k}".to_sym => v.first)
      end
    end
  end
end
