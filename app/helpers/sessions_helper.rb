module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 現在ログイン中のユーザーを返す（いる場合）
  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    # （ユーザーIDにユーザーIDのセッションを代入した結果）ユーザーIDのセッションが存在すれば
    if (user_id = session[:user_id])
      # メモ化らしい
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      # raise  # テストがパスすれば、この部分がテストされていないことがわかる
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    # 演習で、「cookiesの内容を調べてみて、ログアウト後にはsessionが正常に削除されていることを確認してみましょう。」
    # とあるが、いや、session残っとるやんけ。ってなった。
    # しかし、https://teratail.com/questions/61259 を見ると、
    # 「railsのセッションが残る事自体は正常な動作です。ログアウト処理でこのようにuser_idのキーを削除していて、正常にログアウトが出来ているのであれば、何の問題もないという事です。」 ということらしい。
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
