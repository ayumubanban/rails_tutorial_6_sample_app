class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  # default_scopeメソッドは、データベースから要素を取得したときの、デフォルトの順序を指定するメソッド
  # ラムダ式（Stabby lambda）という文法を使っています。これは、Procやlambda（もしくは無名関数）と呼ばれるオブジェクトを作成する文法です。->というラムダ式は、ブロックを引数に取り、Procオブジェクトを返します。このオブジェクトは、callメソッドが呼ばれたとき、ブロック内の処理を評価します。
  # >> -> { puts "foo" }
  # => #<Proc:0x007fab938d0108@(irb):1 (lambda)>
  # >> -> { puts "foo" }.call
  # foo
  # => nil
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,
    content_type: {
      in: %w[image/jpeg image/gif image/png],
      message: 'must be a valid image format'
    },
    size: {
      less_than: 5.megabytes,
      message: 'should be less than 5MB'
    }

  # 表示用のリサイズ済み画像を返す
  def display_image
    # 画像の幅や高さが500ピクセルを超えることのないように制約をかけま
    image.variant(resize_to_limit: [500, 500])
  end
end
