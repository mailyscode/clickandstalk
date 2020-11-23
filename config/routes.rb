Rails.application.routes.draw do
  devise_for :users

  resources :users, only: [:show, :edit, :update] do
    collection do
      get :linkedin
      get :twitter
      get :instagram
    end
  end

  root to: 'pages#home'
end
