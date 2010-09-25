HackU::Application.routes.draw do
  get 'login' => 'sessions#create'
  get 'login/new' => 'sessions#new', :as => 'new_login'
  get 'logout' => 'sessions#destroy'

  get ':action' => 'static', :action => /sample/
  put 'similarity(.:format)' => 'info#similarity'
  put 'facebook_artists(.:format)' => 'info#facebook_artists'

  root :to => 'static#index'
end
