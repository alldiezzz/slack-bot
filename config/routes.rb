Rails.application.routes.draw do
  root :to => 'bot#index'
  get 'start' => 'bot#start'
end
