HackU::Application.routes.draw do
  match ':action' => 'static', :action => /sample/
end
