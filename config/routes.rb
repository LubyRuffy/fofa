Fofa::Application.routes.draw do

  get "lab/ips"
  post "lab/ips"
  get "lab/domains"
  post "lab/domains"
  get "lab/alldomains"
  post "lab/addtask"
  get "lab/gettask"
  get "lab/target"
  get "fofacli/index"
  get "fofacli/getstarted"
  get "fofacli/commandline"
  devise_for :users
  #ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :info do
    collection do
      get :fofacli
      get :library
      get :libraryfull
      get :about
      get :contact
      get :gov_cnt
      get :fee
      get :points
    end
  end

  resources :fofacli do
    collection do
      get :getstarted
      get :commandline
      get :index
      get :download
      get :howtoexploit
      get :howtorule
      get :developer
    end
  end

  resources :exploits do
    collection do
      get :index
    end

    member do
      get :show
    end
  end

  resources :search do
    collection do
      get :index
      get :result
      get :get_web_cnt
      get :get_host_content
      get :get_hosts_by_ip
      get :remove_black_ips
      get :checkapp
      post :checkapp
      get :refresh
    end
  end

  resources :statistic do
    collection do
      get :index
      get :get_server_info
      get :categories
    end
  end

  get "userhost/index"
  post "userhost/addhost"
  get "api/addhost"
  post "api/addhostp"
  get "api/result"
  get "api/resultjs"
  get 'api/addhost'
  get 'ip' => 'api#ip'
  get 'ascii' => 'api#ascii'

  get "my/index"
  #get "my/rules"
  #get "my/saverules"
  get "my/unsave/:id" => "my#unsave"
  delete "my/ruledestroy/:id" => "my#ruledestroy"
  get "my" => "my#index"

  scope '/my' do
    resources :rules do
      member do
        get :save
        get :unsave
      end
    end

    resources :categories do
      collection do
        get :index
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'search#index'

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

  #sidekiq_web_constraint = lambda { |request| request.remote_ip == '127.0.0.1' }
  #constraints sidekiq_web_constraint do
  authenticate :user, lambda { |u| u.isadmin } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

end
