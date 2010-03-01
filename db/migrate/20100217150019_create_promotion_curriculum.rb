class CreatePromotionCurriculum < ActiveRecord::Migration
  def self.up
    create_table :promotion_curriculum do |t|
      t.integer :member_id
      t.integer :school_id
      t.date :beginning_year
      t.date :ending_year
      t.string :degree_obtain

      t.timestamps
    end
  end

  def self.down
    drop_table :promotion_curriculum
  end
end
