ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include ApplicationHelper

  # Add more helper methods to be used by all tests here...

  # テストユーザーがログイン中の場合にtrueを返す
  # ヘルパーメソッドはテストから呼び出せない。よって、current_userを呼び出せない。
  # sessionメソッドはテストでも利用できる
  # logged_in?の代わりに定義
  def is_logged_in?
    !session[:user_id].nil?
  end

  # テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest

  # テストユーザーとしてログインする
  # 統合テストではsessionを直接取り扱うことができないらしい
  # 上のlog_in_as(user)もあり、単体テストか統合テストかを意識せずに、ログイン済みの状態をテストしたいときはlog_in_asメソッドをただ呼び出せば良くなる。これはmatzの説明するダックタイピング（https://www.youtube.com/watch?time_continue=424&v=2Ag8l-wq5qk）の一種らしい
  # テストコードがより便利になるように、log_in_asメソッドではキーワード引数のパスワードと ［remember me］チェックボックスのデフォルト値を、それぞれ'password'と'1'に設定しています。
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: {
      session: {
        email: user.email,
        password: password,
        remember_me: remember_me
      }
    }
  end
end
