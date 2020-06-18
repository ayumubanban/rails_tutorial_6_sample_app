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

  # ヘルパーメソッドはテストから呼び出せない。よって、current_userを呼び出せない。
  # sessionメソッドはテストでも利用できる
  # logged_in?の代わりに定義
  def is_logged_in?
    !session[:user_id].nil?
  end
end
