class ChangeThings < ActiveRecord::Migration
  def self.up
    
    change_table :promotions do |t|
      t.change :year, :string   
    end
    change_table :line_curriculums do |t|
      t.string :place_type
    end
    
    remove_index :members, :login
    
    
  end

  def self.down    
    change_table :promotions do |t|
      t.change :year, :date   
    end
     change_table :line_curriculums do |t|
       t.remove :place_type
     end
     
     #add_index :members, :login, :unique => true
     
     
  end
  
end