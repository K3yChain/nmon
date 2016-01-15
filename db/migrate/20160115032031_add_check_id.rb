class AddCheckId < ActiveRecord::Migration
  def change
    add_column :checks, :check_id, :integer
  end
end
