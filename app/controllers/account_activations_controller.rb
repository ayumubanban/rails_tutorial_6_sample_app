class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    # ここでのparams[:id]はactivation_token
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # update_attributesを1回呼び出すのではなく、update_attributeを2回呼び出していることにご注目ください。update_attributesだとバリデーションが実行されてしまうため、今回のようにパスワードを入力していない状態で更新すると、バリデーションで失敗してしまいます
      user.activate
      # user.update_attribute(:activated, true)
      # user.update_attribute(:activated_at, Time.zone.now)
      log_in user
      flash[:success] = 'Account activated!'
      redirect_to user
    else
      flash[:danger] = 'Invalid activation link'
      redirect_to root_url
    end
  end
end
