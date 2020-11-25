Rails.application.routes.draw do
  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks"
  }

  resources :users, only: [:show, :edit, :update] do
    collection do
      get :linkedin
      get :twitter
      get :instagram
    end
  end
  get 'user/connect', to: 'users#connect', as: :connect
  get 'dashboard', to: 'users#dashboard', as: :dashboard

  root to: 'pages#home'
end
