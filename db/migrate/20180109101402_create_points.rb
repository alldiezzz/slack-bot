class CreatePoints < ActiveRecord::Migration[5.1]
  def change
    create_table :points do |t|
      t.string :user_id
      t.integer :point
      t.string :from_user

      t.timestamps
    end
  end
end
