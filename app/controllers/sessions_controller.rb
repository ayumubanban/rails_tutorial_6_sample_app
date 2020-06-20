class SessionsController < ApplicationController
  def new
  end

  def create
    # テスト内部でassignsメソッドを使うため、通常のローカル変数であったuserをインスタンス変数化する
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      log_in @user
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      # remember user
      # redirect_to @user
      redirect_back_or @user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  # ログインの場合（リスト 8.15とリスト 8.29）と異なり、ログアウト処理は1か所で行える
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
