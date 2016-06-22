module Filters
  class Select
    def self.apply_select(select_params)
      to_select = select_params.join(',')

      filter = if select_params.present?
                 "outFields=#{to_select}"
               else
                 "outFields=*"
               end
      filter
    end
  end
end
