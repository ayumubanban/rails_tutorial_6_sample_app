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

  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    # userがnilになってしまったレアケースもキャッチ
    user && user == current_user
    # user&. == current_user
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

  # このへんのフレンドリーフォワーディングについての実装のコードでは、thoughtbot社が提供するClearance gemを適用しているらしい！[10章脚注6]
  # ってことは、Clearanceのgemをbundle installせんでええのか？

  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  # この命名すごく良いなぁ。関数名と共に引数名も合わせて利用して良い感じにする感じ良いなぁ。
  def redirect_back_or(default)
    # 値がnilでなければsession[:forwarding_url]を評価し、そうでなければデフォルトのURLを使う
    redirect_to(session[:forwarding_url] || default)
    # これをやっておかないと、次回ログインしたときに保護されたページに転送されてしまい、ブラウザを閉じるまでこれが繰り返されてしまう
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    # request.original_urlでリクエスト先が取得できる
    session[:forwarding_url] = request.original_url if request.get? # GETリクエストが送られたときだけ格納
  end
end
