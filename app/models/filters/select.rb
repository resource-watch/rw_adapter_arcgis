module Filters
  class Select
    def self.apply_select(select_params, aggr_func, aggr_by)
      to_select = if aggr_by.present? && aggr_func.present?
                    select_params = select_params.join(',').split(',').delete_if { |p| p.in? aggr_by.join(',').split(',') }
                    select_params = select_params.map { |p| "#{aggr_func}(#{p}::integer) as #{p}" }
                    (select_params << aggr_by.join(',').split(',')).join(',')
                  else
                    select_params.join(',')
                  end

      filter = if select_params.present?
                 "SELECT #{to_select}"
               else
                 "SELECT"
               end
      filter
    end
  end
end
