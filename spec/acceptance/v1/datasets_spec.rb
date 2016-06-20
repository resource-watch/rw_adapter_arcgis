require 'acceptance_helper'

module V1
  describe 'Datasets', type: :request do
    context 'For specific dataset' do
      fixtures :datasets

      let!(:dataset_id) { Dataset.first.id }
      let!(:params) {{"dataset": {
                      "id": "#{dataset_id}",
                      "provider": "Arcgis",
                      "format": "JSON",
                      "name": "Arcgis test api",
                      "data_path": "features",
                      "attributes_path": "fields",
                      "connector_url": "https://services.arcgis.com/uDTUpUPbk8X8mXwl/arcgis/rest/services/Public_Schools_in_Onondaga_County/FeatureServer/0?f=json"
                    }}}

      context 'Without params' do
        it 'Allows access cartoDB data with default limit 1' do
          post "/query/#{dataset_id}", params: params

          data = json['data'][0]['attributes']

          expect(status).to eq(200)
          expect(data['FID']).not_to         be_nil
          expect(data['Status']).not_to      be_nil
          expect(data['City']).to            be_present
          expect(json['data_attributes']).to be_present
          expect(json['data'].length).to     be > 1
        end
      end
    end
  end
end
