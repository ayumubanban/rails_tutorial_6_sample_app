class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  # ログインの場合（リスト 8.15とリスト 8.29）と異なり、ログアウト処理は1か所で行える
  def destroy
    log_out
    redirect_to root_url
  end
end
