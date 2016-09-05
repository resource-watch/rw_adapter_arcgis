Rails.application.routes.draw do
  scope module: :v1, constraints: APIVersion.new(version: 1, current: true) do
    post   'query/:id',    to: 'connectors#show'
    post   'fields/:id',   to: 'connectors#fields'
    post   'datasets',     to: 'connectors#create'
    post   'datasets/:id', to: 'connectors#update'
    delete 'datasets/:id', to: 'connectors#destroy'

    get 'info', to: 'info#info'
    get 'ping', to: 'info#ping'
  end
end
