class AddDeveloperBooleanToUserRoles < ActiveRecord::Migration
  def change
    add_column :user_roles, :developer, :boolean, default: false
  end
end
