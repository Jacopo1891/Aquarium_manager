class CreateData < ActiveRecord::Migration[7.0]
  def change
    create_table :data do |t|
      t.references :aquarium, null: false, foreign_key: true
      t.references :sensor, null: false, foreign_key: true
      t.string :value
      t.date :dataCapture

      t.timestamps
    end
  end
end
