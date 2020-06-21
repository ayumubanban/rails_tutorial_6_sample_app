class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = 'Micropost deleted'
    # これは、HTTPの仕様として定義されているHTTP_REFERERと対応しています。ちなみに「referer」は誤字ではありません。HTTPの仕様では、確かにこの間違ったスペルを使っているのです。一方、Railsは「referrer」という正しいスペルで使っています。
    # このメソッドはフレンドリーフォワーディングのrequest.url変数（10.2.3）と似ていて、一つ前のURLを返します（今回の場合、Homeページになります）。このため、マイクロポストがHomeページから削除された場合でもプロフィールページから削除された場合でも、request.referrerを使うことでDELETEリクエストが発行されたページに戻すことができるので、非常に便利です。ちなみに、元に戻すURLが見つからなかった場合でも（例えばテストではnilが返ってくることもあります）、||演算子でroot_urlをデフォルトに設定しているため、大丈夫です。
    redirect_to request.referrer || root_url
    # このメソッドはRails 5から新たに導入されたらしい
    # redirect_back(fallback_location: root_url)
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
