class AddDescriptionToSensors < ActiveRecord::Migration[7.0]
  def change
    add_column :sensors, :description, :string
  end
end
