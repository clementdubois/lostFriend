class CreatePromotions < ActiveRecord::Migration
  def self.up
    create_table :promotions do |t|
      t.string :degree
      t.date :year

      t.timestamps
    end
  end

  def self.down
    drop_table :promotions
  end
end
