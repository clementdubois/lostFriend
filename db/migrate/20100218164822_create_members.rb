class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table "members", :force => true do |t|
      t.column :login,                     :string, :limit => 40, :default => '', :null => false
      t.column :first_name,                :string, :limit => 100, :default => '', :null => false
      t.column :last_name,                 :string, :limit => 100, :default => '', :null => false
      t.column :civil_state,               :string
      t.column :town,                      :string
      t.column :zipcode,                   :string
      t.column :region,                    :string
      t.column :state,                     :string, :default => "pending"
      t.column :email,                     :string, :limit => 100
      t.column :activation_code,           :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime


    end
    add_index :members, :login, :unique => true
  end

  def self.down
    drop_table "members"
  end
end
