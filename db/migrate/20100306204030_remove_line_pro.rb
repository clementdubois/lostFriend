class RemoveLinePro < ActiveRecord::Migration
  def self.up
    drop_table :line_professional_curriculum
    
    create_table :line_curriculums, :id => false do |t|
      t.integer :member_id
      t.integer :place_id
      t.date :beginning_year
      t.date :ending_year

      t.timestamps
    end
  end

  def self.down
    drop_table :line_curriculums
    
     create_table :line_professional_curriculum, :id => false do |t|
        t.integer :member_id
        t.integer :firm_id
        t.date :beginning_year
        t.date :ending_year

        t.timestamps
      end
  end
end
