Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    omniauth_callbacks: 'users/omniauth_callbacks',
    unlocks: 'users/unlocks'
  }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "home#index"

  resources :categories, only: [:show] do
  end

  resources :projects, except: [:index] do
    collection do
      get :owner
      get :search
      patch :owner, action: :owner_update
    end
    member do
      resources :project_supports, param: :project_support_id, except: [:index, :show, :edit, :new] do

      end
    end
  end

  resources :pledges, only: [:index, :show, :create] do
  end

  resources :payments do
    collection do
      get :mpg
      get :canceled
      post :notify
      post :paid
      post :not_paid_yet
    end
  end
end
