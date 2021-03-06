ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'home', :action => 'index'
  
  map.resources :members, :collection => {:add => :post} do |member|
    member.resources :messages, :collection => {:choose_action => :post}
    member.resources :promotions, :has_many => :line_curriculums
    member.resources :firms, :has_many => :line_curriculums
    member.resources :schools, :has_many => :line_curriculums
  end
  map.resources :invites

  map.resource :session

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.signup  '/signup', :controller => 'members',   :action => 'new'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.accept_invite '/accept/:id', :controller => 'invites', :action => 'accept'  
  map.refuse_invite '/refuse/:id', :controller => 'invites', :action => 'refuse'  
  map.cancel_invite '/cancel/:id', :controller => 'invites', :action => 'cancel'  
  
  map.friends_xml '/member/friends/:id', :controller => 'infos', :action => 'friends'
  
end
