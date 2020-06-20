class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  # before_save { self.email = email.downcase }
  # before_save { email.downcase! }
  # メソッド参照
  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true

  # セキュアにハッシュ化したパスワードを、データベース内のpassword_digestという属性に保存できるようになる。
  # 2つのペアの仮想的な属性（passwordとpassword_confirmation）が使えるようになる。また、存在性と値が一致するかどうかのバリデーションも追加される。
  # authenticateメソッドが使えるようになる（引数の文字列がパスワードと一致するとUserオブジェクトを、間違っているとfalseを返すメソッド）。
  has_secure_password
  # has_secure_passwordでは（追加したバリデーションとは別に）オブジェクト生成時に存在性を検証するようになっているため、空のパスワード（nil）が新規ユーザー登録時に有効になることはありません。（空のパスワードを入力すると存在性のバリデーションとhas_secure_passwordによるバリデーションがそれぞれ実行され、2つの同じエラーメッセージ（"Password can't be blank" or "Password is too short (minimum is 6 characters)"）が表示されるというバグがありましたが（7.3.3）、これで解決できました。）
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  # ref: https://github.com/rails/rails/blob/master/activemodel/lib/active_model/secure_password.rb#L100-L101
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  # 上のUser.digestメソッドも同様、User -> selfとしたり、class << self としてもできるそう。ただ、ここでいうselfは、通常の文脈ではselfはUser「モデル」、つまりユーザーオブジェクトのインスタンスを指すが、User「クラス」を指すということで、分かり難さを生むっぽい。
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    # Rubyにおけるオブジェクト内部への要素代入の仕様
    self.remember_token = User.new_token
    # update_attributeメソッドはバリデーションを素通りさせる。
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # ref: https://github.com/rails/rails/blob/master/activemodel/lib/active_model/secure_password.rb#L121 https://github.com/codahale/bcrypt-ruby/blob/master/lib/bcrypt/password.rb#L65-L68
  # remember_tokenは、attr_accessor :remember_tokenで定義したアクセサとは異なる点に注意。今回の場合、is_password?の引数はメソッド内のローカル変数を参照している。
  # def authenticated?(remember_token)
  # authenticated?メソッドの抽象化
  # 受け取ったパラメータに応じて呼び出すメソッドを切り替える手法を使っている。
  # この一見不思議な手法は「メタプログラミング」と呼ばれています。メタプログラミングを一言で言うと「プログラムでプログラムを作成する」ことです。
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    # 記憶ダイジェストがnilの場合にはreturnキーワードで即座にメソッドを終了している。処理を途中で終了する場合によく使われるテクニックらしい。
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    # selfはモデル内では必須ではない、よね？
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    # これもupdate_attributesと違ってモデルのコールバックやバリデーションが実行されないっぽい
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    # @userがselfに変更されている
    UserMailer.account_activation(self).deliver_now
  end

  # Userモデル内でしか使わないので、外部に公開する必要はない
  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
      # email.downcase!
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
