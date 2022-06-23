#include <ArduinoJson.h>
#include <NTPClient.h>
#include <ArduinoWiFiServer.h>
#include <BearSSLHelpers.h>
#include <CertStoreBearSSL.h>
#include <ESP8266WiFi.h>
#include <ESP8266WiFiAP.h>
#include <ESP8266WiFiGeneric.h>
#include <ESP8266WiFiGratuitous.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266WiFiScan.h>
#include <ESP8266WiFiSTA.h>
#include <ESP8266WiFiType.h>
#include <WiFiClient.h>
#include <WiFiClientSecure.h>
#include <WiFiClientSecureBearSSL.h>
#include <WiFiServer.h>
#include <WiFiServerSecure.h>
#include <WiFiServerSecureBearSSL.h>
#include <WiFiUdp.h>
#include <ESP8266WiFiMulti.h>
#include <LiquidCrystal.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include "ArduinoSecrets.h"
#include <time.h>
#include <sys/time.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WiFi.h>

// LCD connection
#define LCD_PIN_RS D2
#define LCD_PIN_E D3
#define LCD_PIN_D4 D5
#define LCD_PIN_D5 D6
#define LCD_PIN_D6 D7
#define LCD_PIN_D7 D8

#define BUTTON_PIN D0

const int ct =9;
const long utcOffsetInSeconds = 3600;
int buttonState = 0, window = 0;
unsigned long currentMillis, buttondMillis, tempMillis, lastPrintMillis, lastUploadDataMillis = 0, execOnDelay = 100, printOnDelay = 5000, uploadOnDelay = 60000;
bool buttonPushed = false;
String ipAddress = "Not connected";
const char* serverName = SERVER_URL;

// Arduino pin connected to DS18B20 sensor's DQ pin
#define SENSOR_PIN D1

// NPT server and timezone
#define NTP0 "europe.pool.ntp.org"
#define NTP1 "ntp1.inrim.it"
#define TZ "CET-1CEST,M3.5.0/2,M10.5.0/3"
int DOW, MONTH, DATE, YEAR, HOUR, MINUTE, SECOND;
time_t tnow;
char strftime_buf[64];
int GTMOffset = 1;

ESP8266WiFiMulti wifiMulti;
LiquidCrystal lcd(LCD_PIN_RS,LCD_PIN_E,LCD_PIN_D4,LCD_PIN_D5,LCD_PIN_D6,LCD_PIN_D7);;
OneWire oneWire(SENSOR_PIN);
DallasTemperature tempSensor(&oneWire);
WiFiUDP ntpUDP;
StaticJsonDocument<250> json;

NTPClient timeClient(ntpUDP, "0.it.pool.ntp.org", GTMOffset * 60 * 60, 60000);

void setup()
{
  // LCD's number of columns and rows:
  lcd.begin(16, 2);

  // initialize the sensor
  tempSensor.begin();

  // initialize timer
  timeClient.begin();

  configTime(0, 0, NTP0, NTP1);
  // set up TimeZone in local environment
  setenv("TZ", TZ, 3);
  tzset();
  //button as input
  pinMode(BUTTON_PIN, INPUT);

  connectWifi();
}

void loop()
{
  timeClient.update();

  getDateTime();

  currentMillis = millis();

  cronUploadData();

  switchWindow();
}

void switchWindow() {
  if (digitalRead(BUTTON_PIN) == LOW)
  {
    buttondMillis = currentMillis;
    buttonPushed = true;
  }
  if ((unsigned long)(currentMillis - buttondMillis) >= execOnDelay)
  {
    if (buttonPushed)
    {
      buttonPushed = false;
      window++;
      lastPrintMillis = 0;
    }
    showWindow();
  }
}

void showWindow() {
  int windowChosen = window % 3;
  switch (windowChosen) {
    case 1:
      showTemperatura();
      break;
    case 2:
      showIP();
      break;
    default:
      window = 0;
      showWelcome();
      break;
  }
}

void showWelcome()
{
  if ((unsigned long)(currentMillis - lastPrintMillis) >= printOnDelay)
  {
    printTwoLines("    Welcome", "   Working...");
    lastPrintMillis = currentMillis;
  }
}

void showTemperatura()
{
  if ((unsigned long)(currentMillis - lastPrintMillis) >= printOnDelay)
  {
    printTwoLines("Temperatura:", getTemperature() + "C");
    lastPrintMillis = currentMillis;
  }
}

void showIP()
{
  if ((unsigned long)(currentMillis - lastPrintMillis) >= printOnDelay)
  {
    printTwoLines(WiFi.SSID(), "IP:" + ipAddress);
    lastPrintMillis = currentMillis;
  }
}

String getTemperature()
{
  // Send the command to get temperatures
  tempSensor.requestTemperatures();
  // Read temperature in Celsius
  float tempCelsius = tempSensor.getTempCByIndex(0);
  return String(calibrateTemperature(tempCelsius), 2);
}

float calibrateTemperature(float tempInput)
{
  /*
   * Two point calibration 
   * https://www.instructables.com/Calibration-of-DS18B20-Sensor-With-Arduino-UNO/
   */
  float rawHigh = 99.44, rawLow = 36.69, referenceHigh = 99.79, referenceLow = 36.1;
  float rawRange = rawHigh-rawLow, referenceRange = referenceHigh - referenceLow;
  return (((tempInput-rawLow)*referenceRange)/rawRange)+referenceLow;
}

void connectWifi() {
  // Start the Serial communication
  Serial.begin(115200);
  delay(10);

  wifiMulti.addAP(SSIDName1, SSIDPSW);
  wifiMulti.addAP(SSIDName2, SSIDPSW);

  printTwoLines("Connecting...", "");
  delay(2000);

  //Wait for the Wi-Fi to connect: scan for Wi-Fi networks, and connect to the strongest
  while (wifiMulti.run() != WL_CONNECTED) {
    delay(350);
    lcd.setCursor(0, 0);
    lcd.print(".");
    delay(350);
    lcd.print("..");
    delay(350);
    lcd.print("...");
    delay(350);
    lcd.print("....");
    delay(350);
  }

  printTwoLines("Connected to ", WiFi.SSID());
  delay(2000);

  ipAddress = WiFi.localIP().toString();
  printTwoLines(WiFi.SSID(), "IP:" + ipAddress);
  delay(2000);
}

void printTwoLines(String line1, String line2)
{
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(line1);
  lcd.setCursor(0, 1);
  lcd.print(line2);
}

void getDateTime()
{
  struct tm *ti;

  tnow = time(nullptr) + GTMOffset;
  strftime(strftime_buf, sizeof(strftime_buf), "%c", localtime(&tnow));
  ti = localtime(&tnow);
  DOW = ti->tm_wday;
  YEAR = ti->tm_year + 1900;
  MONTH = ti->tm_mon + 1;
  DATE = ti->tm_mday;
  HOUR  = ti->tm_hour;
  MINUTE  = ti->tm_min;
  SECOND = ti->tm_sec;
}

void cronUploadData()
{
  if ((unsigned long)(currentMillis - lastUploadDataMillis ) >= uploadOnDelay)
  {
    uploadData();
    lastUploadDataMillis = currentMillis;
  }
}

void uploadData()
{
  WiFiClient client;
  HTTPClient http;
  if (WiFi.status() == WL_CONNECTED)
  {
    http.begin(client, serverName);
    http.addHeader("Content-Type", "application/json");
    int httpResponseCode = http.POST(getRequest());
    http.end();
  }
  else
  {
    ipAddress = "Not connected";
    connectWifi();
    lastUploadDataMillis = 0;
  }
}

String getRequest()
{
  String tempToJson = getTemperature();
  tempToJson.replace(".", "");
  json["aquarium_id"] = AQUARIUM_ID;
  json["sensor_id"] = SENSOR_ID;
  json["value"] = tempToJson;

  String request;
  serializeJson(json, request);
  return request;
}