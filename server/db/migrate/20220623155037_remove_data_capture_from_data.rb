class RemoveDataCaptureFromData < ActiveRecord::Migration[7.0]
  def change
    remove_column :data, :dataCapture, :date
  end
end
