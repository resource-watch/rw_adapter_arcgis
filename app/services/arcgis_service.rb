# frozen_string_literal: true
require 'uri'

class ArcgisService
  def initialize(connect_data_url, connect_data_path, options = {})
    @connect_data_url   = connect_data_url
    @connect_data_path  = connect_data_path
    @options_hash       = options
    initialize_options
  end

  def connect_data
    standard_params = '&returnGeometry=false&returnDistinctValues=false&f=json'
    query_to_run    = if options_query["errors"].present?
                        ""
                      elsif @options_hash.present?
                        query_params = "/query#{options_query}#{standard_params}".gsub('&&','&').gsub('??','?').gsub('queryoutFields', 'query?outFields')
                        query_params = query_params + '&where=1=1' unless query_params.include?('&where')
                        query_params
                      else
                        "/query?#{index_query}#{standard_params}"
                      end

    url =  URI.encode(@connect_data_url[/[^\?]+/].gsub('/query',''))
    puts "Base URL: #{url}"
    url += query_to_run
    puts "Query to run. #{query_to_run}"
    if not options_query["errors"].present?
      ConnectorService.connect_to_provider(url, @connect_data_path)
    else
    end
  end

  private

    def initialize_options
      @options = QueryParams.sanitize(@options_hash)
      @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    end

    def index_query
      'outFields=*&where=1=1'
    end

    def options_query
      query_path  = ''
      query_path += @outFields.present? ? "outFields=#{@outFields}&" : 'outFields=*&'
      query_path += @where.present?     ? "where=#{@where}&"         : 'where=1=1&'
      query_path += "tableName=#{@tableName}&"                                   if @tableName.present?
      query_path += "orderByFields=#{@orderByFields}&"                           if @orderByFields.present?
      query_path += "resultRecordCount=#{@resultRecordCount}&"                   if @resultRecordCount.present?
      query_path += "groupByFieldsForStatistics=#{@groupByFieldsForStatistics}&" if @groupByFieldsForStatistics.present?
      query_path += "outStatistics=#{@outStatistics}&"                           if @outStatistics.present?
      query_path += "statisticType=#{@statisticType}&"                           if @statisticType.present?
      query_path += "returnCountOnly=true&"                                      if @returnCountOnly.present?
      sql_path    = "#{@sql}"                                                    if @sql.present?
      geostore    = @geostore                                                    if @geostore.present?

      filter  = if @sql.present?
                  QueryService.connect_to_query_service(sql_path, geostore)
                else
                  query_path
                end

      filter += Filters::Limit.apply_limit(@limit) if @limit.present? && !@limit.include?('all')
      puts "Filter: #{filter}"
      filter
    end
end
