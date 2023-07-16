class AlexaController < ApplicationController
  def getLastTemperature
    @data = Datum.last(1)
    render json: @data, only: [:id, :aquarium_id, :sensor_id, :value, :created_at] 
  end

  def getMinTemperatureToday
    @data = Datum.today_data().order("value ASC").limit(1)
    render json: @data, only: [:id, :aquarium_id, :sensor_id, :value, :created_at]  
  end

  def getMaxTemperatureToday
    @data = Datum.today_data().order("value DESC").limit(1)
    render json: @data, only: [:id, :aquarium_id, :sensor_id, :value, :created_at] 
  end

  def getHistoryDay
    @data = Datum.today_data().filter_by_sensor(1)
                  .group_by_hour(:created_at, format: "%d %a %H:%M")
                  .average(:value)
                  .map { |created_at, average_value| { created_at: created_at, value: average_value } }
    render json: @data
  end

  def getHistory
    @data = Datum.two_days_data().filter_by_sensor(1)
                  .group_by_hour(:created_at, format: "%d %a %H:%M")
                  .average(:value)
                  .map { |created_at, average_value| { created_at: created_at, value: average_value } }
    render json: @data
  end
end
