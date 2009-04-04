ActionController::Routing::Routes.draw do |map|
  map.resources :chats, :collection => { :user_list => :get }
end
