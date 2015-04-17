# -*- encoding : utf-8 -*-
class SetDefaultForUserRoleIDinUsers < ActiveRecord::Migration
  def change
    remove_column :users, :user_role_id, :integer
    add_column :users, :user_role_id, :integer, default: 1
  end
end
