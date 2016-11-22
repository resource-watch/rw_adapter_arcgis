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
    cache_options  = "results_#{self.id}"
    cache_options += "_#{options}" if options.present?

    if results = Rails.cache.read(cache_key(cache_options))
      results
    else
      get_data = ArcgisService.new(@connector_url, @data_path, options)
      results  = get_data.connect_data

      Rails.cache.write(cache_key(cache_options), results.to_a) if results.present?
    end
    results
  end

  def cache_key(cache_options)
    "query_#{ cache_options }"
  end

  def recive_dataset_meta
    @recive_attributes = ConnectorService.connect_to_provider(@connector_url, @attributes_path)
    @data_horizon      = @data_horizon.present? ? @data_horizon : 0
    if @recive_attributes.to_s.include?('error')
      nil
    elsif @recive_attributes.any?
      { dataset: { id: @id, data_columns: @recive_attributes, data_horizon: @data_horizon } }
    end

  end

  def data_columns
    Dataset.find(@id).try(:data_columns)
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
