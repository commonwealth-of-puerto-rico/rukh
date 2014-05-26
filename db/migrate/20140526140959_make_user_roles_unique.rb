class MakeUserRolesUnique < ActiveRecord::Migration
  def change
    add_index :user_roles, :role_name, unique: true
  end
end