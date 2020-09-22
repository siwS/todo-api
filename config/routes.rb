Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resource :users, only: [:create]
      post "login", to: "users#login"
      get "autologin", to: "users#auto_login"

      jsonapi_resources :tasks
      jsonapi_resources :tags
    end
  end

end
