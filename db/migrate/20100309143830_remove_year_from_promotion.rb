class RemoveYearFromPromotion < ActiveRecord::Migration
  def self.up
    remove_column :promotions, :year
    change_column :line_curriculums, :ending_year, :integer
    change_column :line_curriculums, :beginning_year, :integer
  end

  def self.down
    add_column :promotions, :year, :integer
    change_column :line_curriculums, :ending_year, :date
    change_column :line_curriculums, :beginning_year, :date
  end
end
