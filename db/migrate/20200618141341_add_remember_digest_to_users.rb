class AddRememberDigestToUsers < ActiveRecord::Migration[6.0]
  def change
    # 記憶ダイジェストはユーザーが直接読み出すことはないので（かつ、そうさせてはならないので）、remember_digestカラムにインデックスを追加する必要はありません。
    add_column :users, :remember_digest, :string
  end
end
