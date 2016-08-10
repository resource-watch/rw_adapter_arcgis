class ConnectorFieldsSerializer < ActiveModel::Serializer
  attributes :table_name, :fields

  def fields
    object.data_columns
  end
end
