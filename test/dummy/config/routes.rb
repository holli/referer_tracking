Rails.application.routes.draw do

  resources :users

  mount RefererTracking::Engine => "/referer_tracking"
end
