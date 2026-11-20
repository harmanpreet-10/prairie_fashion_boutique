
Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "products#index"

  resources :products, only: [:index, :show]
  resources :categories, only: [:index, :show]

  resource :cart, only: [:show] do
    post "add", to: "carts#add"
    patch "update_item", to: "carts#update_item"
    delete "remove", to: "carts#remove"
    delete "clear", to: "carts#clear"
  end

  resources :orders, only: [:new, :create, :show]

  get "checkout", to: "orders#new", as: :checkout

  get "up" => "rails/health#show",
      as: :rails_health_check
end
