class DataValueChangeDecimal < ActiveRecord::Migration[7.0]
  def up
    change_column :data, :value, "decimal USING CAST( value AS decimal)"
  end

  def down
    change_column :data, :value, :string, default: "0"
  end
end
