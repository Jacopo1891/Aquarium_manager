class CreateSensors < ActiveRecord::Migration[7.0]
  def change
    create_table :sensors do |t|
      t.string :name
      t.string :guid
      t.string :unitOfMeasure

      t.timestamps
    end
  end
end
