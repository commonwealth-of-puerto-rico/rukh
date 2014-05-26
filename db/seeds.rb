# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


## Populate User Roles table w/ user role names
user_roles_list = [
  # :normal_user, #probably already added so will throw validation error.
  :admin  
]

user_roles_list.each do |role_name|
  UserRole.create(role_name: role_name)
end

## Create Admin user
User.create(email: 'webmaster@jca.pr.gov', password: 'password', 
  user_role_id: UserRole.find_by_role_name(:admin).id)