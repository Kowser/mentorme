Mentorme::Application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, :controllers => {registrations: 'registrations', confirmations: 'confirmations'}

  devise_scope :user do
    root to: 'devise/registrations#new'
    get 'sign_out', to: 'devise/sessions#destroy'
    get 'sign_in', to: 'devise/sessions#new'
  end
  
  resources :notes
  resources :goals, only: [:destroy, :update]
  resources :attachments
  resources :references, except: [:show, :index]
  resources :organizations_users
  get 'references/:token', to: 'references#edit'
  get 'references/', to: 'references#edit'
  get 'references/notify/:id', to: 'references#resend_notification', as: 'reference_resend_notification'
  get 'enrollments/form_select/', to: 'enrollments#form_select'
  get 'enrollments/template_fields/', to: 'enrollments#template_fields'
  get 'check_ins/attendees/:id', to: 'check_ins#attendees', as: 'check_ins_attendees'
  get 'background_checks/api_checkr', to: 'background_checks#api_checkr'

  resources :users do
    resources :background_checks, only: [:create]
    resources :check_ins
    resources :goals, only: [:index, :update]
    resources :matches
    resources :responses, as: 'custom_form_responses'
    get 'edit_templates/', to: 'users#edit_templates'
  end
  
  resources :organizations, except: [:index] do
    get 'dashboard', to: 'organizations#show', as: 'dashboard'
    get 'staff', to: 'organizations#staff', as: 'staff'
    get 'new_staff', to: 'organizations#new_staff_form'
    get 'import', to: 'organizations#import', as: 'import'
    get 'preferences', to: 'organizations#preferences', as: 'preferences'
    post 'import_csv', to: 'organizations#import_csv', as: 'import_csv'
    post 'update_users', to: 'organizations#update_users'
    post 'create_staff', to: 'organizations#create_staff'
    patch 'update_user/:id', to: 'organizations#update_user', as: 'update_user'

    resources :background_checks, only: [:index, :new, :create]
    resources :goals
    resources :check_ins
    resources :matches
    # get 'matches/find', to: 'matches#find', as: 'find_matches'
    # get 'matches/results', to: 'matches#results', as: 'show_results'
    # post 'matches/results', to: 'matches#results', as: 'find_results'
    resources :references, only: [:index, :show]
    resources :custom_onboardings, as: 'enrollments', controller: 'enrollments'
    get 'custom_onboardings/:id/preview', to: 'enrollments#preview', as: 'enrollment_preview'
    resources :responses, as: 'custom_form_responses', only: [:create] # needed to allow preview @object to work with 'applications' path
    get 'custom_onboardings/:id/report', to: 'enrollments#report', as: 'enrollment_report'
    resources :applications, as: 'custom_forms', controller: 'forms'
    get 'applications/:id/preview', to: 'responses#preview', as: 'custom_form_preview'
    resources :emails, as: 'custom_emails'
    get 'emails/:id/preview', to: 'emails#preview', as: 'custom_email_preview'

    resources :users do
      get 'edit_templates/', to: 'users#edit_templates'
      resources :responses, as: 'custom_form_responses'
    end
  end
end
