class QueryParams < Hash
  def initialize(params)
    sanitized_params = {
      sql:                        params['sql']                        || nil,
      where:                      params['where']                      || nil,
      outFields:                  params['outFields']                  || nil,
      tableName:                  params['tableName']                  || nil,
      orderByFields:              params['orderByFields']              || nil,
      resultRecordCount:          params['resultRecordCount']          || nil,
      groupByFieldsForStatistics: params['groupByFieldsForStatistics'] || nil,
      outStatistics:              params['outStatistics']              || nil,
      statisticType:              params['statisticType']              || nil,
      limit:                      params['limit']                      ||= standard_limit(params)
    }

    super(sanitized_params)
    merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

  private

    def standard_limit(params)
      if params.present?
        ['all']
      else
        [1]
      end
    end
end
