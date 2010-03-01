class CreateFriends < ActiveRecord::Migration
  def self.up

    create_table :friends, {:id => false} do |t|
        t.column :member_id, :integer, :null => false
        t.column :member_id_friend, :integer, :null => false      # target of the relationship
        t.timestamps   
    end
      
  end

  def self.down
    drop_table :friends
  end
end
