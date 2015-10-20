#include "HX711.h"
#define DOUT  3
#define CLK  2
#define ledout1 10
#define ledout2 11
HX711 scale(DOUT, CLK);
float calibration_factor = -2060;
long offset = 7899600;
void setup() {
  Serial.begin(57600);
  pinMode(ledout1, OUTPUT);
  pinMode(ledout2, OUTPUT);
  digitalWrite(ledout1,HIGH);
  digitalWrite(ledout2,LOW);
  scale.set_scale(calibration_factor);
  scale.set_offset(offset);
  /*
  scale.read_average();
  long zero_factor = scale.read_average(); //Get a baseline reading
  Serial.print("Zero factor: "); //This can be used to remove the need to tare the scale. Useful in permanent scale projects.
  Serial.println(zero_factor);
  */  
}
int under_counter = 0;
boolean drinking = false;
void loop() {
  int value = scale.get_units(1);
  Serial.println(value);
  /*
  if(!drinking && abs(value) > 0 && abs(value) < 3)
  { 
    if(under_counter++>=10)
    {
      scale.tare();
    }
  }
  else
    under_counter=0;
  */
}
void serialEvent() {
  while (Serial.available()) {
    String inString = Serial.readStringUntil(' ');
    if(inString == "W")
    {  
      drinking = false;
      digitalWrite(ledout1,HIGH);
      digitalWrite(ledout2,LOW);      
    }
    else if(inString == "D")
    {  
      drinking = true;
      digitalWrite(ledout1,LOW);
      digitalWrite(ledout2,HIGH);      
    }
    else if(inString == "T")
    {
      offset = scale.read_average();
      scale.set_offset(offset);
      Serial.println(offset);
    }
  }
}
