require 'curb'
require 'uri'
require 'oj'

class ArcgisService
  def initialize(connect_data_url, connect_data_path, options = {})
    @connect_data_url   = connect_data_url
    @connect_data_path  = connect_data_path
    @options_hash       = options
    initialize_options
  end

  def connect_data
    standard_params = '&returnGeometry=false&returnDistinctValues=false&returnIdsOnly=false&returnCountOnly=false&f=json'
    query_to_run    = if @options_hash.present?
                        "/query?#{options_query}#{standard_params}"
                      else
                        "/query?#{index_query}#{standard_params}"
                      end

    url =  URI.encode(@connect_data_url[/[^\?]+/].gsub('/query',''))
    url += query_to_run

    ConnectorService.connect_to_provider(url, @connect_data_path)
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
      # SELECT
      filter = Filters::Select.apply_select(@select)
      # WHERE
      filter += '&where=1=1'                                   unless @filter.present?
      filter += '&where='                                      if @not_filter.present? || @filter.present?
      filter += Filters::FilterWhere.apply_where(@filter, nil) if @filter.present?
      # WHERE NOT
      filter += ' AND ' if @not_filter.present? && @filter.present?
      filter += Filters::FilterWhere.apply_where(nil, @not_filter) if @not_filter.present?
      # GROUP BY
      filter += Filters::GroupBy.apply_group_by(@select, @aggr_by, @aggr_func) if @aggr_func.present? && @aggr_by.present? && @select.present?
      # ORDER
      filter += Filters::Order.apply_order(@order) if @order.present?
      # Limit
      filter += Filters::Limit.apply_limit(@limit) if @limit.present? && !@limit.include?('all')
      # TODO: Validate query structure
      filter
    end
end
