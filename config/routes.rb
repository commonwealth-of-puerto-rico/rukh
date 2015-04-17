# -*- encoding : utf-8 -*-
Rails.application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'static_pages#home'
  
  match '/help',          to: 'static_pages#help',    via: 'get'
  match '/home',          to: 'static_pages#home',    via: 'get'
  match '/dev',           to: 'static_pages#dev',     via: 'get'
  match 'debtor/search',  to: 'debtors#search',       via: 'get', as: 'search'
  
  match '/import',        to: 'import#create',        via: 'post'
  match '/import',        to: 'import#new',           via: 'get'
  
  match '/email',         to: 'debts#preview_email',  via: 'get'
  match '/email/send',    to: 'debts#send_email',     via: 'post' 
  #TODO refactor w/ debt id in path

  resources :debtors 
  resources :debts, except: :destroy do 
    resources :mail_logs, except: :destroy
  end

  match '/letter',        to: 'static_pages#modeloSC_724', via: 'get'
  # get "static_pages/home"
  # get "static_pages/help"
  
  
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
