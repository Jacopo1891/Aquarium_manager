# Aquarium manager

Log Aquarium's data (temperature) from ESP8862 module.

### Website page
The page shows the maximum and minimum temperature of the current day.
The graph shows the temperature of the last 2 days, divided by hours, calculated with the average of the samples recorded every minute.

<p align="center">
<a  href="#">
<img src="https://user-images.githubusercontent.com/5861330/209579521-6e82c761-1d98-4604-8df8-0d51f2c4f037.jpg" alt="WebPage" align="center" style="width:80%;"/>
</a>
</p>

### ESP8862 module
The ESP8862 shows the aquarium temperature updated every 5 seconds.
The red key changes information on LCD showing device's ip.
<p align="center">
<a href="#">
<img src="https://user-images.githubusercontent.com/5861330/209584726-28dffaba-256a-4339-b8b7-2ebf2e56dbf1.jpg" alt="ESP8266" align="center" style="width:50%;"/>
</a>
</p>

### Alexa integration
Taking advantage of NodeRed and the Alexa skill, it is possible to ask the assistant information about aquarium temperature.

##### Example:
>*"Alexa what is the temperature of the aquarium?"*
>
>*"The temperature of the aquarium is 25.06°"*
