HackU::Application.routes.draw do
  get 'login' => 'sessions#create'
  get 'login/new' => 'sessions#new', :as => 'new_login'

  get ':action' => 'static', :action => /graph/
  put 'similarity(.:format)' => 'info#similarity'
  get 'statistics(.:format)' => 'info#statistics'

  get 'graph' => 'static#graph'

  root :to => 'sessions#redirect'

  get 'grabfriends(.:format)' => 'info#grabfriends'
end
