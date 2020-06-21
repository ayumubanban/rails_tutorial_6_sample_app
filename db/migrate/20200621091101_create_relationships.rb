class CreateRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end

    # このリレーションシップは今後follower_idとfollowed_idで頻繁に検索することになるので、それぞれのカラムにインデックスを追加
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # あるユーザーが同じユーザーを2回以上フォローすることを防ぐ
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
