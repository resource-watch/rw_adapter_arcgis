# frozen_string_literal: true
class DatasetParams < Hash
  def initialize(params)
    params[:connector_url]   ||= params[:connectorUrl]
    params[:table_name]      ||= params[:tableName]
    params[:data_path]       ||= params[:dataPath]
    params[:data_horizon]    ||= params[:dataHorizon]
    params[:attributes_path] ||= params[:attributesPath]
    sanitized_params = {
      id: params[:id] || nil,
      name: params[:name] || nil,
      provider: params[:provider] || nil,
      format: params[:format] || nil,
      connector_url: params[:connector_url] || nil,
      table_name: params[:table_name] ||= table_name_param(params[:connector_url]),
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

  def table_name_param(connector_url)
    URI(connector_url).path.split(/services|FeatureServer/)[1].gsub('/','')
  end
end
