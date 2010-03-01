class CreateInvites < ActiveRecord::Migration
  
  def self.up
    
    create_table :invites do |t|
        t.column :member_id, :integer, :null => false           # source of the relationship
        t.column :member_id_target, :integer, :null => false    # target of the relationship
        t.column :code, :string                                 # random invitation code
        t.column :message, :text                                # invitation message
        t.column :is_accepted, :boolean, :default => false
        t.column :accepted_at, :timestamp                       # when did they accept?
        t.timestamps
        
      end
    
  end

  def self.down
    drop_table :invites
  end
end
