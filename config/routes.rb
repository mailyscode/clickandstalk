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
  get 'dashboard', to: 'users#dashboard', as: :dashboard
  end

  root to: 'pages#home'
end
