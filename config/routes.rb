require 'sidekiq/web'
Rails.application.routes.draw do

  # Campaign1
  resources :trnotifications do
    member do
      get 'status' # /trnotifications/:id/status
      get 'status_locked_submissions' # /trnotifications/:id/status_locked_submissions
      get 'enotify' # /trnotifications/:id/enotify
      post 'submit' # /trnotifications/:id/submit
    end

  end

  get '/', to: redirect(configatron.web.rdr )

  #mount Sidekiq::Web, at: '/sidekiq'
  mount Crono::Web, at: '/crono'

end
