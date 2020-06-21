require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test 'profile display' do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    # 演習：Homeページに表示されている統計情報に対してテストを書いてみましょう。ヒント: リスト 13.28で示したテストに追加してみてください。同様にして、プロフィールページにもテストを追加してみましょう。
    # なんかよくわからんけど text: @user.following.countじゃダメだった
    assert_select 'a>strong#following.stat', "#{@user.following.count}"
    assert_select 'a>strong#followers.stat', "#{@user.followers.count}"
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
