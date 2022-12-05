Rails.application.routes.draw do
  get 'alexa/getLastTemperature'
  get 'alexa/getMinTemperatureToday'
  get 'alexa/getMaxTemperatureToday'
  get 'alexa/getMaxTemperatureToday'
  get 'alexa/getLastTemperature'
  resources :data
  resources :aquaria
  resources :sensors
  resources :alexa
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
   root "home#index"
end
