json.extract! datum, :id, :aquarium_id, :sensor_id, :value, :dataCapture, :created_at, :updated_at
json.url datum_url(datum, format: :json)
