class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    # @users = User.all
    # :pageパラメーターにはparams[:page]が使われているが、これはwill_paginateによって自動的に生成される
    # 演習：有効でないユーザーは表示する意味がない
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    # 演習：有効でないユーザーは表示する意味がない
    # &&だとroot_urlとの論理的な結び付きが強くなりすぎてしまい、不適切らしい。が、andだとrubocopに怒られるのねぇ…
    redirect_to root_url and return unless @user.activated?
    # debugger # これでbyebug起動できる
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      # UserMailer.account_activation(@user).deliver_now
      flash[:info] = 'Please check your email to activate your account.'
      redirect_to root_url

      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"
      # redirect_to @user
      # redirect_to user_url(@user)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    # アクション名と違う名前のビューをrenderで明示的に呼び出す
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def user_params
      # 編集してもよい安全な属性だけを更新させる
      # patch /users/17?admin=1 とかを送信されるのを防ぐ
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # 管理者かどうか確認
    # ある程度の腕前を持つ攻撃者なら、コマンドラインでDELETEリクエストを直接発行するという方法でサイトの全ユーザーを削除してしまうことができる。サイトを正しく防衛するには、destroyアクションにもアクセス制御を行う必要がある
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
