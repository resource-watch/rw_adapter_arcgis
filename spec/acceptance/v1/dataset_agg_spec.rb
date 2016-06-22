require 'acceptance_helper'

module V1
  describe 'Datasets AGG', type: :request do
    context 'Aggregation for specific dataset' do
      fixtures :datasets

      let!(:dataset_id) { Dataset.last.id }
      let!(:params)     {{"dataset": {
                          "id": "#{dataset_id}",
                          "provider": "Arcgis",
                          "format": "JSON",
                          "name": "Arcgis test api",
                          "data_path": "features",
                          "attributes_path": "fields",
                          "connector_url": "https://services.arcgis.com/uDTUpUPbk8X8mXwl/arcgis/rest/services/Public_Schools_in_Onondaga_County/FeatureServer/0?f=json"
                        }}}

      let!(:params_q)   {{"dataset": {
                          "id": "#{dataset_id}",
                          "provider": "Arcgis",
                          "format": "JSON",
                          "name": "Arcgis test api",
                          "data_path": "features",
                          "attributes_path": "fields",
                          "connector_url": "https://services.arcgis.com/uDTUpUPbk8X8mXwl/arcgis/rest/services/Public_Schools_in_Onondaga_County/FeatureServer/0/query?outFields=District,City&where=1=1&f=json"
                        }}}

      context 'Aggregation with params' do
        it 'Allows aggregate Arcgis data by one attribute' do
          post "/query/#{dataset_id}?select[]=District&filter=(Score<<100 <and> Score>=1)&filter_not=(FID==56)&aggr_by[]=Free_Lunch&aggr_func=sum&order[]=District", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to                         eq(13)
          expect(data[0]['attributes']['District']).to eq('Baldwinsville')
          expect(json['data_attributes']).to           be_present
        end

        it 'Allows aggregate Arcgis data by two attributes with order DESC' do
          post "/query/#{dataset_id}?select[]=District,City&aggr_by[]=Free_Lunch,Reduced_Lu&aggr_func[]=sum,avg&order[]=-City", params: params_q

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to                           eq(28)
          expect(data[0]['attributes']['City']).to       eq('Tully')
          expect(data[0]['attributes']['Free_Lunch']).to eq(0.21)
          expect(data[0]['attributes']['Reduced_Lu']).to eq(0.075)
        end

        it 'Return error message for wrong params' do
          post "/query/#{dataset_id}?select[]=Districtsss,City&aggr_by[]=Free_Lunch,Reduced_Lu&aggr_func[]=sum,avg&order[]=-City", params: params

          data = json['data']

          expect(status).to                      eq(200)
          expect(data['error']['details'][0]).to eq('Unable to perform query. Please check your parameters.')
        end
      end
    end
  end
end
