Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    root "dashboard#index"

    resources :course_lists do
      patch :reorder, on: :collection
      resources :course_list_sections do
        resources :videos, except: [:show]
        resources :images, except: [:show]
        resources :text_contents, except: [:show]
        resources :reviews, except: [:show]
      end
    end

    resources :users, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :unions
    resources :course_progresses, only: [:index]
    resource :frontpage_content, only: [:edit, :update]
  end

  resources :course_lists, only: [:index, :show] do
    post :complete, on: :member

    resource :quiz, only: [:show], controller: "course_list_quizzes"
    post "quiz", to: "course_list_quizzes#submit", as: :submit_quiz

    resources :course_list_sections, only: [:show] do
      post :complete, on: :member
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
