class ApplicationController < ActionController::Base
  include SessionsHelper

  private

    # ログイン済みユーザーかどうか確認
    # 命名はrequire_loginとかのがしっくりくる感…
    # UsersでもMicropostsでも使うのでこちらに移動
    # JavaやC++といった言語の挙動とは異なり、RubyのPrivateメソッドは継承クラスからも呼び出すことができる
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
