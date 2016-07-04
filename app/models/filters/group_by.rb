module Filters
  class GroupBy
    def self.apply_group_by(group_by_params, aggr_by, aggr_func)
      to_select = group_by_params.is_a?(Array) ? group_by_params.join(',') : group_by_params
      aggr_by   = aggr_by.is_a?(Array) ? aggr_by.join(',').split(',') : aggr_by.split(',')
      aggr_func = aggr_func.is_a?(Array) ? aggr_func.join(',').split(',') : aggr_func.split(',')

      filter = ''
      filter += '&groupByFieldsForStatistics='
      filter += to_select
      filter += '&outStatistics='
      filter += '['

      aggr_by.each_index do |i|
        filter += ', ' if i > 0
        filter += { statisticType: "#{aggr_func[i]}", onStatisticField: "#{aggr_by[i]}", outStatisticFieldName: "#{aggr_by[i]}" }.to_json
      end

      filter += ']'
      filter
    end
  end
end
