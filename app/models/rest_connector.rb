# frozen_string_literal: true
class RestConnector
  extend ActiveModel::Naming
  include ActiveModel::Serialization
  include HashFinder
  attr_reader :id, :table_name

  def initialize(params)
    @dataset_params = if params[:connector].present? && params[:connector].to_unsafe_hash.recursive_has_key?(:attributes)
                        params[:connector][:dataset][:data].merge(params[:connector][:dataset][:data][:attributes].to_unsafe_hash)
                      else
                        params[:dataset] || params[:connector]
                      end
    initialize_options
  end

  def data(options = {})
    get_data = ArcgisService.new(@connector_url, @data_path, options)
    results  = get_data.connect_data
    results
  end

  def cache_key(cache_options)
    "query_#{ cache_options }"
  end

  def recive_dataset_meta
    @recive_attributes = ConnectorService.connect_to_provider(@connector_url, nil, @attributes_path)
    Rails.logger.info "Recive attributes: #{@recive_attributes}"
    @data_horizon      = @data_horizon.present? ? @data_horizon : 0
    if @recive_attributes.to_s.include?('error')
      nil
    elsif @recive_attributes.present?
      { dataset: { id: @id, data_columns: convert(@recive_attributes), data_horizon: @data_horizon } }
    end
  end

  def convert(recived_attributes)
    new_attributes = {}
    case recived_attributes
    when Array
      recived_attributes.each do |v|
        new_attributes[v['name']] = { type: v['type'] }
      end
    when Hash
      new_attributes = recived_attributes
    else
      new_attributes = nil
    end
    new_attributes
  end

  def data_columns
    convert(Dataset.find(@id).try(:data_columns))
  end

  def data_horizon
    Dataset.find(@id).try(:data_horizon)
  end

  private

    def initialize_options
      @options = DatasetParams.sanitize(@dataset_params)
      @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    end
end
