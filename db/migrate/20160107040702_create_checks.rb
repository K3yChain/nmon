class CreateChecks < ActiveRecord::Migration
  def change
    create_table :checks do |t|
      t.string :check_name
      t.string :check_hostname

      t.timestamps null: true
    end
  end
end
