Fofa::Application.routes.draw do

  devise_for :users
  #ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "info/gov"
  get "info/library"
  get "info/about"
  get "info/contact"
  get "info/gov_cnt"
  get "statistic/index"
  get "statistic/get_server_info"
  get "search/index"
  get "search/result"
  get "search/get_web_cnt"
  get "search/get_host_content"
  get "userhost/index"
  post "userhost/addhost"
  get "api/addhost"
  post "api/addhostp"
  get "api/result"
  get 'api/addhost'

  get "my/index"
  get "my/rules"
  get "my/saverules"
  get "my" => "my#index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'search#index'

  resources :rules
  #get "rules" => "rules#index"
  get "save/:id" => "rules#save"

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
  require "resque_web"
  ResqueWeb::Engine.eager_load!
  resque_web_constraint = lambda { |request| request.remote_ip == '127.0.0.1' }
  constraints resque_web_constraint do
      mount ResqueWeb::Engine => "/resque_web"
  end
end
