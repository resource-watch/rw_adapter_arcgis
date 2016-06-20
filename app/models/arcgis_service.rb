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
    # query_to_run = if @options_hash.present?
    #                  "/query?#{options_query}&f=json"
    #                else
    #                  "/query?#{index_query}&f=json"
    #                end

    query_to_run = "/query?#{index_query}&f=json"

    url =  URI.encode(@connect_data_url[/[^\?]+/])
    url += query_to_run

    @c = Curl::Easy.http_get(URI.escape(url)) do |curl|
      curl.headers['Accept']       = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
    end

    Oj.load(@c.body_str.force_encoding(Encoding::UTF_8))[@connect_data_path] || Oj.load(@c.body_str.force_encoding(Encoding::UTF_8))
  end

  private

    def initialize_options
      @options = QueryParams.sanitize(@options_hash)
      @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    end

    def index_query
      "where=1=1&returnGeometry=false&returnDistinctValues=false&returnIdsOnly=false&returnCountOnly=false&outFields=*"
    end

    def options_query
      # SELECT
      filter = Filters::Select.apply_select(@select, @aggr_func, @aggr_by)
      # WHERE
      filter += ' WHERE ' if @not_filter.present? || @filter.present?
      filter += Filters::FilterWhere.apply_where(@filter, nil) if @filter.present?
      # WHERE NOT
      filter += ' AND' if @not_filter.present? && @filter.present?
      filter += Filters::FilterWhere.apply_where(nil, @not_filter) if @not_filter.present?
      # GROUP BY
      filter += Filters::GroupBy.apply_group_by(@aggr_by) if @aggr_func.present? && @aggr_by.present?
      # ORDER
      filter += Filters::Order.apply_order(@order) if @order.present?
      # Limit
      filter += Filters::Limit.apply_limit(@limit) if @limit.present? && !@limit.include?('all')
      # TODO: Validate query structure
      filter
    end
end
