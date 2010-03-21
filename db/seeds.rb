# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)


# Generate seeds for the promotion

['DUT Informatique', 'License logiciel libre'].each do |degree|
  Promotion.create(:degree => degree)
end

# Generate members for testing
admin = Member.find_or_create_by_login(:login => "admin", :first_name => "admin",
              :last_name => "act", :civil_state => "m", :email => "admin@truc.com", 
              :activation_code => "azerty", :password => "azerty", :password_confirmation => "azerty")


activated = Member.find_or_create_by_login(:login => "activate", :first_name => "activate",
              :last_name => "act", :civil_state => "m", :email => "active@truc.com", 
              :activation_code => "azerty", :password => "azerty", :password_confirmation => "azerty")
              
admin.state = "active"
admin.save
activate.state = "active"
activate.save

pending = Member.find_or_create_by_first_name(:state => "pending", :first_name => "pending",
              :last_name => "pend", :activation_code => "azerty")
              
gervais = Member.find_or_create_by_first_name(:state => "activate", :first_name => "frederic",
              :last_name => "gervais", :activation_code => "azerty")              
              
admin.save
activated.save
pending.save(false)



