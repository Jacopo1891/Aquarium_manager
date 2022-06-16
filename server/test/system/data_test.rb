require "application_system_test_case"

class DataTest < ApplicationSystemTestCase
  setup do
    @datum = data(:one)
  end

  test "visiting the index" do
    visit data_url
    assert_selector "h1", text: "Data"
  end

  test "should create datum" do
    visit data_url
    click_on "New datum"

    fill_in "Aquarium", with: @datum.aquarium_id
    fill_in "Datacapture", with: @datum.dataCapture
    fill_in "Sensor", with: @datum.sensor_id
    fill_in "Value", with: @datum.value
    click_on "Create Datum"

    assert_text "Datum was successfully created"
    click_on "Back"
  end

  test "should update Datum" do
    visit datum_url(@datum)
    click_on "Edit this datum", match: :first

    fill_in "Aquarium", with: @datum.aquarium_id
    fill_in "Datacapture", with: @datum.dataCapture
    fill_in "Sensor", with: @datum.sensor_id
    fill_in "Value", with: @datum.value
    click_on "Update Datum"

    assert_text "Datum was successfully updated"
    click_on "Back"
  end

  test "should destroy Datum" do
    visit datum_url(@datum)
    click_on "Destroy this datum", match: :first

    assert_text "Datum was successfully destroyed"
  end
end
