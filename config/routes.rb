Rails.application.routes.draw do
  get "questions/new"
  get "questions/create"
  # Community Engagement Form flow
  resources :engagement_forms, only: [:new, :create, :show] do
    member do
      get :pdf
    end
  end
  
  # Initial questions page
  resources :questions, only: [:new, :create]
  
  # Individual engagement type flows
  resources :jobs, only: [:new, :create]
  resources :students, only: [:new, :create]
  resources :work_programs, only: [:new, :create]
  resources :volunteers, only: [:new, :create]
  
  # Summary page
  get "summary/:engagement_form_id", to: "summary#show", as: :summary
  
  # Root route
  root "engagement_forms#new"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
