Rails.application.routes.draw do
  resources :notifications, only: [ :show, :create ] do
    collection do
      post :bulk, to: "notifications#bulk_create"
    end
  end

  scope "user/:user_id" do
    resources :notification_preferences
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
