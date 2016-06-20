class RestConnector
  include ActiveModel::Serialization
  attr_reader :id, :name, :provider, :format, :connector_url, :data_path, :attributes_path

  def initialize(params)
    @dataset_params = params[:dataset] || params[:connector]
    initialize_options
  end

  def data(options = {})
    get_data = ArcgisService.new(@connector_url, @data_path, options)
    get_data.connect_data
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
