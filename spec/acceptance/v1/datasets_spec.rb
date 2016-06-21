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
        it 'Allows access Arcgis data with default limit 1' do
          post "/query/#{dataset_id}", params: params

          data = json['data'][0]['attributes']

          expect(status).to eq(200)
          expect(data['FID']).not_to         be_nil
          expect(data['Status']).not_to      be_nil
          expect(data['City']).to            be_present
          expect(json['data_attributes']).to be_present
          expect(json['data'].length).to     eq(1)
        end
      end

      context 'With params' do
        it 'Allows access all available Arcgis data with limit all' do
          post "/query/#{dataset_id}?limit=all", params: params

          expect(status).to eq(200)
          expect(json['data'].length).to be > 10
        end

        it 'Allows access Arcgis data with order ASC' do
          post "/query/#{dataset_id}?order[]=FID", params: params

          data = json['data'][0]['attributes']

          expect(status).to eq(200)
          expect(data['FID']).to eq(1)
        end

        it 'Allows access Arcgis data with order DESC' do
          post "/query/#{dataset_id}?order[]=-FID", params: params

          data = json['data'][0]['attributes']

          expect(status).to eq(200)
          expect(data['FID']).to eq(124)
        end

        it 'Allows access Arcgis data details with select and order' do
          post "/query/#{dataset_id}?select[]=FID,Free_Lunch&order[]=Free_Lunch", params: params

          data = json['data'][0]['attributes']

          expect(status).to eq(200)
          expect(data['FID']).to            eq(13)
          expect(data['Free_Lunch']).not_to be_nil
        end

        # it 'Allows access Arcgis data details with select, filter and order DESC' do
        #   post "/query/#{dataset_id}?select[]=FID,Free_Lunch&filter=(FID==1,2,4,5 <and> Free_Lunch><'0.05'..'1.5')&order[]=-Free_Lunch", params: params

        #   data = json['data'][0]['attributes']

        #   expect(status).to eq(200)
        #   expect(data['FID']).to        eq(1)
        #   expect(data['Free_Lunch']).to eq('0.05')
        # end

        # it 'Allows access Arcgis data details with select, filter_not and order' do
        #   post "/query/#{dataset_id}?select[]=FID,Free_Lunch&filter_not=(FID>=4 <and> Free_Lunch><'0.03'..'1.5')&order[]=Free_Lunch", params: params

        #   data = json['data'][0]['attributes']

        #   expect(status).to eq(200)
        #   expect(data['FID']).to            eq(2)
        #   expect(data['Free_Lunch']).not_to be_nil
        # end

        # it 'Allows access Arcgis data details with select, all filters and order DESC' do
        #   post "/query/#{dataset_id}?select[]=FID&filter=(FID==5)&filter_not=(FID==4 <and> Free_Lunch><'0.06'..'1.5')&order[]=-Free_Lunch", params: params

        #   data = json['data'][0]['attributes']

        #   expect(status).to eq(200)
        #   expect(data['FID']).to            eq(5)
        #   expect(data['Free_Lunch']).not_to be_present
        # end

        # it 'Allows access Arcgis data details for all filters, order and without select' do
        #   post "/query/#{dataset_id}?filter=(FID<<5)&filter_not=(FID==4 <and> Free_Lunch><'0.07'..'2')&order[]=-FID&limit=2", params: params

        #   data = json['data']

        #   expect(status).to eq(200)
        #   expect(data.size).to                 eq(2)
        #   expect(data[0]['attributes']['FID']).to            eq(3)
        #   expect(data[0]['attributes']['Free_Lunch']).not_to be_nil
        #   expect(data[1]['attributes']['FID']).to            eq(2)
        # end

        # it 'Allows access Arcgis data details for all filters without select and order' do
        #   post "/query/#{dataset_id}?filter=(FID>=2)&filter_not=(FID==4 <and> Free_Lunch><'0.05'..'1')&limit=3", params: params

        #   data = json['data']

        #   expect(status).to eq(200)
        #   expect(data[0]['attributes']['FID']).to            eq(2)
        #   expect(data[0]['attributes']['Free_Lunch']).not_to be_nil
        #   expect(data[1]['attributes']['FID']).to            eq(5)
        # end

        # it 'Allows access Arcgis data details for all filters' do
        #   post "/query/#{dataset_id}?select[]=FID,Free_Lunch&filter=(FID<<5 <and> Free_Lunch>='0.05')&filter_not=(FID==4 <and> Free_Lunch><'0.08'..'1.5')&order[]=-Free_Lunch", params: params

        #   data = json['data']

        #   expect(status).to eq(200)
        #   expect(data.size).to                 eq(1)
        #   expect(data[0]['attributes']['FID']).to            eq(2)
        #   expect(data[0]['attributes']['Free_Lunch']).not_to be_nil
        # end

        it 'Allows access Arcgis data with limit rows' do
          post "/query/#{dataset_id}?limit=2", params: params

          expect(status).to eq(200)
          expect(json['data'].length).to eq(2)
        end

        it 'Allows access Arcgis data with limit rows as array filter' do
          post "/query/#{dataset_id}?limit[]=3", params: params

          expect(status).to eq(200)
          expect(json['data'].length).to eq(3)
        end

        # it 'Allows access Arcgis data details for all filters without select and order' do
        #   post "/query/#{dataset_id}?select[]=FID&filter=(FID>=1)&filter_not=(FID==4 <and> Free_Lunch><'0.01'..'1.5')&order[]=-Free_Lunch&limit=2", params: params

        #   expect(status).to eq(200)
        #   expect(json['data'].length).to eq(2)
        # end
      end
    end
  end
end
