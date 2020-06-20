require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {
      user: {
        name: '',
        email: 'foo@invalid',
        password: 'foo',
        password_confirmation: 'bar'
      }
    }

    assert_template 'users/edit'
    assert_select 'div.alert', 'The form contains 4 errors.'
  end

  # こういった正しい振る舞いというのは一般に忘れがちですが、受け入れテスト（もしくは一般的なテスト駆動開発）では先にテストを書くので、効果的なユーザー体験について考えるようになります。
  test 'successful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = 'Foo Bar'
    email = 'foo@bar.com'
    # ユーザー名やメールアドレスを編集するときに毎回パスワードを入力するのは不便なので、（パスワードを変更する必要が無いときは）パスワードを入力せずに更新できると便利←それはそう
    patch user_path(@user), params: {
      user: {
        name: name,
        email: email,
        password: '',
        password_confirmation: ''
      }
    }
    assert_not flash.empty?
    assert_redirected_to @user
    # @user.reloadを使って、データベースから最新のユーザー情報を読み込み直して、正しく更新されたかどうかを確認
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: {
      user: {
        name: name,
        email: email,
        password: '',
        password_confirmation: ''
      }
    }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  # ここで書くべきテスト内容なのかは怪しいが…
  # 演習での、フレンドリーフォワーディングで、渡されたURLに初回のみ転送されていることの確認
  test 'should redirect forwarding_url only first time' do
    get edit_user_path(@user)
    assert_redirected_to login_url
    assert_equal session[:forwarding_url], edit_user_url(@user)
    log_in_as(@user)
    assert_nil session[:forwarding_url]
    delete logout_path
    log_in_as(@user)
    assert_redirected_to user_url(@user)
  end
end
