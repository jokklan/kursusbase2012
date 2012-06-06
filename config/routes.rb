Kursusbase2012::Application.routes.draw do


  scope "(:locale)", :locale => /en|da/ do
    # match "/students/login_dtu" => redirect("https://auth.dtu.dk/dtu/index.jsp?service=http://localhost:3000/")
    # match "/students/login" => "students#login"
    # match "/students/logged_in" => "students#logged_in", :as => "logged_in_student"
    # match "/students/get_courses" => "students#get_courses", :as => "get_courses_student"
    # resources :students
    
    # get 'signup', to: 'students#new', as: 'signup'
    get 'login', to: 'sessions#new', as: 'login'
    post 'login', to: 'application#login', as: 'sessions'
    put 'login', to: 'application#login', as: 'sessions'
    get 'logout', to: 'sessions#destroy', as: 'logout'
    
    resources :courses
    resources :keywords
    resources :course_types
	  
    # get "/", to: 'student#show', as: "show_student"
		
		post "search", to: "courses#index", as: "search"
		
		root :to => 'students#show'
  end
  
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
