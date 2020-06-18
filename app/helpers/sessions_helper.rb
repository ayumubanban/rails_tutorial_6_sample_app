module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    if session[:user_id]
      # メモ化らしい
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    # 演習で、「cookiesの内容を調べてみて、ログアウト後にはsessionが正常に削除されていることを確認してみましょう。」
    # とあるが、いや、session残っとるやんけ。ってなった。
    # しかし、https://teratail.com/questions/61259 を見ると、
    # 「railsのセッションが残る事自体は正常な動作です。ログアウト処理でこのようにuser_idのキーを削除していて、正常にログアウトが出来ているのであれば、何の問題もないという事です。」 ということらしい。
    session.delete(:user_id)
    @current_user = nil
  end
end
