class CreateLineProfessionalCurriculum < ActiveRecord::Migration
  def self.up
    create_table :line_professional_curriculum do |t|
      t.integer :member_id
      t.integer :firm_id
      t.date :beginning_year
      t.date :ending_year

      t.timestamps
    end
  end

  def self.down
    drop_table :line_professional_curriculum
  end
end
