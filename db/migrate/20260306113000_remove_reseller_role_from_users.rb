class RemoveResellerRoleFromUsers < ActiveRecord::Migration[7.1]
  def up
    User.where(role: "reseller").update_all(role: "member")
  end

  def down
    # No rollback because reseller role is removed from the app.
  end
end
