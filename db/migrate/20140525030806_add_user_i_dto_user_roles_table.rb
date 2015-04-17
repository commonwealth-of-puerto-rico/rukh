# -*- encoding : utf-8 -*-
class AddUserIDtoUserRolesTable < ActiveRecord::Migration
  def change
    add_column :user_roles, :user_id, :integer
    add_column :users, :user_role_id, :integer
  end
end
