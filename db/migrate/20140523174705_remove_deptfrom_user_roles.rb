# -*- encoding : utf-8 -*-
class RemoveDeptfromUserRoles < ActiveRecord::Migration
  def change
    remove_column :user_roles, :dept
  end
end
