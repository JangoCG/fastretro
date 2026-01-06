Rails.application.routes.draw do
  root "landing_page#show"

  resources :users, only: %i[ show edit update destroy ] do
    scope module: :users do
      resource :role, only: :update
      resources :email_addresses, param: :token, only: %i[ new create ] do
        resource :confirmation, only: %i[ show create ], module: :email_addresses
      end
    end
  end
  resources :retros do
    scope module: :retros do
      resource :waiting_room, only: :show
      resource :action_review, only: :show
      resource :brainstorming, only: :show
      resource :grouping, only: :show
      resource :voting, only: :show
      resource :discussion, only: :show
      resource :complete, only: :show
      resource :export, only: :show
      resource :start, only: :create
      resource :action_review_selection, only: :create
      resource :finished, only: :update
      resource :finish_brainstorming, only: :create
      resource :phase_transition, only: :create
      resource :phase_back, only: :create
      resources :feedback_groups, only: %i[create destroy] do
        delete :remove_feedback, on: :collection
      end
      resources :votes, only: %i[create destroy]
      resource :highlight, only: %i[update destroy]
    end
    resources :feedbacks, only: %i[ new create show edit update destroy ] do
      resource :publish, only: :create, module: :feedbacks
    end
    resources :actions, only: %i[ new create show edit update destroy ] do
      resource :publish, only: :create, module: :actions
      resource :completion, only: :update, module: :actions
    end
  end

  # Account settings
  namespace :account do
    resource :join_code, only: %i[ show edit update destroy ]
    resource :settings, only: %i[ show update ]
    resources :subscriptions, only: :create
    resource :billing_portal, only: :show
  end

  # Join codes for multi-account
  get "join/:code", to: "join_codes#new", as: :join
  post "join/:code", to: "join_codes#create"

  # Retro invite links (combines join code + retro access)
  get "invite/:code/retro/:retro_id", to: "retros/invites#show", as: :retro_invite
  post "invite/:code/retro/:retro_id", to: "retros/invites#create"

  # User verifications
  namespace :users do
    resources :verifications, only: %i[ new create ]
  end

  # Session management with magic links
  resource :session do
    scope module: :sessions do
      resources :transfers
      resource :magic_link do
        post :resend, on: :member
      end
      resource :menu
    end
  end

  get "/signup", to: redirect("/signup/new")
  get "/landing_page", to: redirect("/")

  # Signup flow
  resource :signup, only: %i[ new create ] do
    collection do
      scope module: :signups, as: :signup do
        resource :completion, only: %i[ new create ]
      end
    end
  end

  # Tenanted entry point (after account switch)
  resource :landing, only: :show

  # My namespace for nav menu and user-specific resources
  namespace :my do
    resource :menu
  end

  # Site feedback (app feedback from users)
  resource :site_feedback, only: %i[new create]

  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check

  # SEO
  get "sitemap.xml", to: "sitemaps#show", as: :sitemap, defaults: { format: :xml }

  # Legal pages
  get "imprint", to: "legal#imprint", as: :imprint
  get "privacy_policy", to: "legal#privacy_policy", as: :privacy_policy

  # Blog
  get "blog", to: "blog#index", as: :blog
  get "blog/:id", to: "blog#show", as: :blog_post

  # Alternative pages (SEO)
  get "alternative/easyretro", to: "alternatives#easyretro", as: :alternative_easyretro

  # Admin
  namespace :admin do
    resource :stats, only: :show
  end

  # Stripe webhooks
  post "stripe/webhooks", to: "stripe/webhooks#create"
end
