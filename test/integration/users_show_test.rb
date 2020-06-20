require 'test_helper'

# 演習：有効なユーザーだけを表示するコードのテスト
class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'successful show' do
    log_in_as(@user)
    get user_path(@user)
    assert_template 'users/show'
  end

  test 'unsuccessful show because the user is not activated' do
    log_in_as(@user)
    @user.activated = false
    @user.save
    get user_path(@user)
    assert_redirected_to root_url
  end
end
