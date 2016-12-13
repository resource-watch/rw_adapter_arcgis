require 'acceptance_helper'

module V1
  describe 'Datasets AGG', type: :request do
    context 'Aggregation for specific dataset' do
      fixtures :datasets
      fixtures :service_settings

      let!(:dataset_id) { Dataset.last.id }
      let!(:params)     {{"dataset": {
                          "id": "#{dataset_id}",
                          "provider": "featureservice",
                          "format": "JSON",
                          "name": "Arcgis test api",
                          "dataPath": "features",
                          "attributesPath": "fields",
                          "connectorUrl": "https://services.arcgis.com/uDTUpUPbk8X8mXwl/arcgis/rest/services/Public_Schools_in_Onondaga_County/FeatureServer/0?f=json"
                        }}}

      let!(:params_q)   {{"connector": {"dataset": {"data": {
                                      "id": "#{dataset_id}",
                                      "attributes": {"provider": "featureservice",
                                                                              "format": "JSON",
                                                                              "name": "Arcgis test api",
                                                                              "dataPath": "features",
                                                                              "attributesPath": "fields",
                                                                              "connectorUrl": "https://services.arcgis.com/uDTUpUPbk8X8mXwl/arcgis/rest/services/Public_Schools_in_Onondaga_County/FeatureServer/0/query?outFields=District,City&where=1=1&f=json"
                                    }}}}}}

      let(:group_attr_1) { URI.encode(Oj.dump([{"onStatisticField":"Free_Lunch","statisticType":"sum","outStatisticFieldName":"Free_Lunch"}])) }
      let(:group_attr_2) { URI.encode(Oj.dump([{"onStatisticField":"Free_Lunch","statisticType":"sum","outStatisticFieldName":"Free_Lunch"},{"onStatisticField":"Reduced_Lu","statisticType":"avg","outStatisticFieldName":"Reduced_Lu"}])) }

      context 'Aggregation with params' do
        it 'Allows aggregate Arcgis data by one attribute using fs' do
          post "/query/#{dataset_id}?outFields=District&outStatistics=#{group_attr_1}&tableName=Public_Schools_in_Onondaga_County&where=Score < 100 and Score >= 1 and FID != 56&groupByFieldsForStatistics=District&orderByFields=District ASC", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to                         eq(13)
          expect(data[0]['attributes']['District']).to eq('Baldwinsville')
        end

        it 'Allows aggregate Arcgis data by one attribute using sql' do
          post "/query/#{dataset_id}?sql=select District,sum(Free_Lunch) as Free_Lunch from Public_Schools_in_Onondaga_County where Score < 100 and Score >= 1 and FID != 56 group by District order by District ASC", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to                         eq(13)
          expect(data[0]['attributes']['District']).to eq('Baldwinsville')
        end

        it 'Allows aggregate Arcgis data by two attributes with order DESC using sql' do
          post "/query/#{dataset_id}?sql=select District,City,sum(Free_Lunch) as Free_Lunch,avg(Reduced_Lu) as Reduced_Lu from Public_Schools_in_Onondaga_County group by District,City order by City DESC", params: params_q

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to                           eq(28)
          expect(data[0]['attributes']['City']).to       eq('Tully')
          expect(data[0]['attributes']['Free_Lunch']).to eq(0.21)
          expect(data[0]['attributes']['Reduced_Lu']).to eq(0.075)
        end

        it 'Allows aggregate Arcgis data by two attributes with order DESC using fs' do
          post "/query/#{dataset_id}?outFields=District,City&outStatistics=#{group_attr_2}&tableName=Public_Schools_in_Onondaga_County&where=Score < 100 and Score >= 1 and FID != 56&groupByFieldsForStatistics=District,City&orderByFields=City DESC", params: params_q

          data = json['data']

          expect(status).to eq(200)
          expect(data.size).to                           eq(19)
          expect(data[0]['attributes']['City']).to       eq('Syracuse')
          expect(data[0]['attributes']['Free_Lunch']).to eq(0.15)
          expect(data[0]['attributes']['Reduced_Lu']).to eq(0.09)
        end

        it 'Return error message for wrong params' do
          post "/query/#{dataset_id}?sql=select Districtsss,City,sum(Free_Lunch) as Free_Lunch,avg(Reduced_Lus) as Reduced_Lu from Public_Schools_in_Onondaga_County group by District,City order by City ASC", params: params

          data = json['data']

          expect(status).to                      eq(200)
          expect(data['error']['details'][0]).to eq('Unable to perform query. Please check your parameters.')
        end

        it 'Select count' do
          post "/query/#{dataset_id}?sql=select count(*) from Public_Schools_in_Onondaga_County", params: params

          data = json['data']

          expect(status).to eq(200)
          expect(data['count']).to eq(124)
        end
      end
    end
  end
end
