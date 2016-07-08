#include <VarSpeedServo.h>

VarSpeedServo servo1;
VarSpeedServo servo2;
VarSpeedServo servo3;
int vel=20;
int angle;
int init_angle=0;
int final_angle=90;

void setup() {
  // put your setup code here, to run once:
  
  servo1.attach(8);
  servo2.attach(9);
  servo3.attach(10);
  Serial.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:

  

     //vel=analogRead(0);
     angle=init_angle;
     servo1.write(angle,vel,false);
     servo2.write(angle,vel,false);
     servo3.write(angle,vel,true);

    Serial.println(angle);
    delay(100);

    angle=final_angle;
    servo1.write(angle,vel,false);
    servo2.write(angle,vel,false);
    servo3.write(angle,vel,true);
    Serial.println(angle);

  

}
