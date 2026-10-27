Rails.application.routes.draw do
  # トップページ
  root "home#index"

  # ゴルフ練習場一覧ページ
  resources :golf_ranges, only: %i[index show]


  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA関連
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
