class RemoveGuidFromSensors < ActiveRecord::Migration[7.0]
  def change
    remove_column :sensors, :guid, :string
  end
end
