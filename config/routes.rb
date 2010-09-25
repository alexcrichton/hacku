HackU::Application.routes.draw do
  get ':action' => 'static', :action => /sample/
  put 'similarity(.:format)' => 'info#similarity'
  put 'facebook_artists(.:format)' => 'info#facebook_artists'

  root :to => 'static#index'
end
