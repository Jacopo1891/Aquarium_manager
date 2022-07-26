class Datum < ApplicationRecord
  include Filterable

  belongs_to :aquarium
  belongs_to :sensor

  scope :filter_by_sensor, -> (sensor_id) { where(sensor_id: sensor_id) }

  scope :week_data, -> { where("created_at >= ?", 1.week.ago.midnight) }
  
  scope :two_days_data, -> { where("created_at >= ?", 2.days.ago.midnight) }
  
  scope :one_day_data, -> { where("created_at >= ?", 1.day.ago.midnight) }

  scope :filter_by_start_date, -> { where("created_at >= ?", date.to_date) }

  scope :filter_by_end_date, -> { where("created_at <= ?", date.to_date) }

  scope :today_data, -> { where("created_at >= ?", 0.day.ago.midnight) }

end