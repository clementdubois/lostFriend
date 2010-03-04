class CreateTheMessages < ActiveRecord::Migration
  def self.up
    drop_table :messages
    create_table :messages do |t|
      t.column :body, :text
      t.column :subject, :string, :default => ""
      t.column :headers, :text
      t.column :sender_id, :integer, :null => false
      t.column :conversation_id, :integer
      t.column :sent, :boolean, :default => false
      t.column :created_at, :datetime, :null => false
    end
    #i use foreign keys but its a custom method, so i'm leaving it up to you if you want them.
  end

  def self.down
    drop_table :messages
     create_table :messages do |t|
        t.integer :sender_id
        t.integer :receiver_id
        t.string :title
        t.text :content

        t.timestamps
      end
  end
end
