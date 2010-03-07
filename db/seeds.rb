# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)


# Generate seeds for the promotion

years = []
 i=1970
 
 
 while(i <= 2010) do
   years << i
   i = i+1
 end

['DUT Informatique', 'License logiciel libre'].each do |degree|
  years.each do |year|
    Promotion.create(:year => year.to_s, :degree => degree)
  end
  
end


