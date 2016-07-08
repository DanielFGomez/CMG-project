#include <VarSpeedServo.h>

VarSpeedServo servo1;
VarSpeedServo servo2;
VarSpeedServo servo3;
int vel=5;
int angle;
int init_angle=0;
int final_angle=90;
int t1,t2;

void setup() {
  // put your setup code here, to run once:
  
  servo1.attach(8);
  servo2.attach(9);
  servo3.attach(10);
  Serial.begin(115200);
  Serial.print("Vel_signal t angle");
}

void loop() {
  // put your main code here, to run repeatedly:

  
     vel+=5;
     angle=init_angle;
     t1=millis();
     servo1.write(angle,vel,false);
     servo2.write(angle,vel,false);
     servo3.write(angle,vel,true);
     t2=millis();
    
    Serial.print(vel);
    Serial.print(" ");
    Serial.print(t2-t1);
    Serial.print(" ");
    Serial.println(abs(init_angle-final_angle));
    delay(100);

    angle=final_angle;
    t1=millis();
     servo1.write(angle,vel,false);
     servo2.write(angle,vel,false);
     servo3.write(angle,vel,true);
     t2=millis();
    
    Serial.print(vel);
    Serial.print(" ");
    Serial.print(t2-t1);
    Serial.print(" ");
    Serial.println(abs(init_angle-final_angle));

  

}
