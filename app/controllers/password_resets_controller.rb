class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new'
    end
  end

  def edit
  end

  def update
    # 新しいパスワードが空文字列になっていないか（ユーザー情報の編集ではOKだった）
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    # 新しいパスワードが正しければ、更新する
    elsif @user.update(user_params)
      log_in @user
      # 仮にログアウトして離席したとしても、２時間以内であれば、そのコンピューターの履歴からパスワード再設定フォームを表示させ、パスワードを更新してしまうことができてしまいます（しかもそのままログイン機構まで突破されてしまいます!）。この問題を解決するため
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    # 無効なパスワードであれば失敗させる（失敗した理由も表示する）
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 有効なユーザーかどうか確認する
    def valid_user
      # ここでのparams[:id]はreset_tokenかな？
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # パスワード再設定のためのトークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = 'Password reset has expired.'
        redirect_to new_password_reset_url
      end
    end
end
