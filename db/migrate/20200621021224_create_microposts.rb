class CreateMicroposts < ActiveRecord::Migration[6.0]
  def change
    create_table :microposts do |t|
      # Text型の方が表現豊かなマイクロポストを実現できるらしい
      t.text :content
      # references型を利用すると、自動的にインデックスと外部キー参照付きのuser_idカラムが追加され、UserとMicropostを関連付けする下準備をしてくれる
      # リスト13.3には null: false はなかったけど、そのままにしとこ。だって、userなしのmicropostはありえんはずやし、いけるやろ
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # ↑ え？自動的には付与してくれてなかったけど…
    # user_idに関連付けられたすべてのマイクロポストを作成時刻の逆順で取り出しやすくなる
    # user_idとcreated_atの両方を１つの配列に含めている点にも注目。こうすることでActive Recordは、両方のキーを同時に扱う複合キーインデックス（Multiple Key Index）作成する
    add_index :microposts, [:user_id, :created_at]
  end
end
