class Datum < ApplicationRecord
  include Filterable

  belongs_to :aquarium
  belongs_to :sensor

  scope :week_data, -> { where("created_at >= ?", 1.week.ago.midnight) }
  
  scope :filter_by_start_date, -> (date) { where("created_at >= ?", date.to_date) }

  scope :filter_by_end_date, -> (date) { where("created_at <= ?", date.to_date) }
end