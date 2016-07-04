class DatasetParams < Hash
  def initialize(params)
    sanitized_params = {
      id: params[:id] || nil,
      name: params[:name] || nil,
      provider: params[:provider] || nil,
      format: params[:format] || nil,
      connector_url: params[:connector_url] || nil,
      data_path: params[:data_path] || 'features',
      data_horizon: params[:data_horizon] || nil,
      attributes_path: params[:attributes_path] || 'fields'
    }

    super(sanitized_params)
    merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end
end
