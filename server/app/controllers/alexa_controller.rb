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
end
