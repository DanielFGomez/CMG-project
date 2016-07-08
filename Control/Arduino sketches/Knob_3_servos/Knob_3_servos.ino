#include <VarSpeedServo.h>

VarSpeedServo servo1;
VarSpeedServo servo2;
VarSpeedServo servo3;

int angle=0;

void setup() {
  // put your setup code here, to run once:
  
  servo1.attach(8);
  servo2.attach(9);
  servo3.attach(10);
  Serial.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:

  
    
    angle=map(analogRead(0),0,1023,0,180);
    Serial.println(angle);
    servo1.write(angle,20,false);
    servo2.write(angle,20,false);
    servo3.write(angle,20,false);
 

}
