class AlexaController < ApplicationController
  def getLastTemperature
    @data = Datum.last(1)
    render json: @data, only: [:id, :aquarium_id, :sensor_id, :value, :created_at] 
  end

  def getMinTemperatureToday
    @data = Datum.today_data().minimum(:value)
    render json: @data, only: [:id, :aquarium_id, :sensor_id, :value, :created_at]  
  end

  def getMaxTemperatureToday
    @data = Datum.today_data().maximum(:value)
    render json: @data, only: [:id, :aquarium_id, :sensor_id, :value, :created_at] 
  end
end
