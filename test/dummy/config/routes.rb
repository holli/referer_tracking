Rails.application.routes.draw do

  resources :users do
    post :create_with_custom_saving, :on => :collection
    post :build_without_saving, :on => :collection
  end

  mount RefererTracking::Engine => "/referer_tracking"
end
