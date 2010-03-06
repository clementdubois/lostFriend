class ChangeThings < ActiveRecord::Migration
  def self.up
    
    change_table :promotions do |t|
      t.change :year, :string   
    end
  end

  def self.down    
    change_table :promotions do |t|
      t.change :year, :date   
    end
     
     
  end
  
end