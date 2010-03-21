class Promotion < ActiveRecord::Base
  has_many :line_curriculums, :as => :place
  has_many :members, :through => :line_curriculums
  
  def self.list_degree
    [
      '',
      'DUT Informatique',
      'Licence logiciel libre'
    ]
  end
  
  def self.list_year
    years = []
     i=1970
     years << ''
     while(i <= 2010) do
       years << i
       i = i+1
     end
     
     years
  end
  
end
