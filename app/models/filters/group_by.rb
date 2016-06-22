module Filters
  class GroupBy
    def self.apply_group_by(select_params, aggr_by, aggr_func)
      to_select  = select_params.join(',')
      group_by   = aggr_by.is_a?(Array) ? aggr_by.join(',').split(',') : aggr_by.split(',')
      group_func = aggr_func.is_a?(Array) ? aggr_func.join(',').split(',') : aggr_func.split(',')

      filter = ''
      filter += '&groupByFieldsForStatistics='
      filter += to_select
      filter += '&outStatistics='
      filter += '['

      group_by.each_index do |i|
        filter += ', ' if i > 0
        filter += { statisticType: "#{group_func[i]}", onStatisticField: "#{group_by[i]}", outStatisticFieldName: "#{group_by[i]}" }.to_json
      end

      filter += ']'
      filter
    end
  end
end
