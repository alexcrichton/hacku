HackU::Application.routes.draw do
  get 'login' => 'sessions#create'
  get 'login/new' => 'sessions#new', :as => 'new_login'

  get ':action' => 'static', :action => /sample|graph/
  put 'similarity(.:format)' => 'info#similarity'
  put 'facebook_artists(.:format)' => 'info#facebook_artists'

  get 'graph' => 'static#graph'

  root :to => 'sessions#redirect'
end
