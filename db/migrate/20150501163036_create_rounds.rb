#ZM: No db constraints
class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.references :deck
      t.references :user
      t.boolean :live, default: 'true'

      t.timestamps
    end
  end
end
