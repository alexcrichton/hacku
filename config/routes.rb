HackU::Application.routes.draw do
  get ':action' => 'static', :action => /sample/
  put 'similarity(.:format)' => 'info#similarity'

  root :to => 'static#index'
end
