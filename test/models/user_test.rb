require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "  "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "  "
    assert_not @user.valid?
  end

  # 単に50を上限として手頃な値を使うことにします。つまりここでは、51文字の名前は長すぎることを検証します
  test "name should not be too long" do
    @user.name = "a"*51
    assert_not @user.valid?
  end

  # ほとんどのデータベースでは文字列の上限を255としているので、それに合わせて255文字を上限とします
  test "email should not be too long" do
    @user.name = "a"*244 + "@example.com"
    assert_not @user.valid?
  end

  test "email vaildation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    # データベースの値に合わせて更新するreloadメソッド
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimun length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
end
