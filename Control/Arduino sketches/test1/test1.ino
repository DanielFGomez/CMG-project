

//Este codigo sirve para probar el funcionamiento del prototipo.
//
//Permite controlar la posicion de los servos con un potenciometro

#include <VarSpeedServo.h>
#include <SerialCommand.h>
#include <SoftwareSerial.h> 

SerialCommand SCmd; 

VarSpeedServo servo1;
VarSpeedServo servo2;
VarSpeedServo servo3;

VarSpeedServo motors;

double servo2gimbal=1;

int angle;

void setup() {
  
    servo1.attach(8);
    servo2.attach(9);
    servo3.attach(10);
    
    servo1.write(45*servo2gimbal);
    servo2.write(45*servo2gimbal);
    servo3.write(45*servo2gimbal);
    
    motors.attach(11);
    motors.writeMicroseconds(1000);
    
    Serial.begin(9600);

    
    
    
   
    SCmd.addCommand("start",start); //Start motors 
    SCmd.addCommand("m",set_motors); //sets a given signal in micoseconds
}

void loop() {
  // put your main code here, to run repeatedly:
    SCmd.readSerial(); 
    
    angle=map(analogRead(0),0,1023,0,180);//0.71 se refiere a la conversion de angulo del servo a angulo del cardan. Se tiene un rango de 0-90 para el cardan
    //Serial.println(angle/servo2gimbal);
    servo1.write(angle,20,false);
    servo2.write(angle-10,20,false);
    servo3.write(angle-60,20,false);

}

void start(){
    Serial.println("Starting motors");
    int i;
    for (i=1000;i<=1050;i++){
      motors.writeMicroseconds(i);
      delay(10);
    }
    Serial.println("Motors on");
}

void set_motors(){
  int motor_signal;  
  char *arg; 
  arg = SCmd.next();
  int t0=millis();
  if (arg != NULL) 
  {
    motor_signal=atoi(arg);    // Converts a char string to an integer
    int delta;
    delta=motor_signal-motors.readMicroseconds();
    Serial.print("Changing motor signal to: ");
    Serial.println(motor_signal);
    
    double i;
    for(i=20;i>=0;i--){
      motors.writeMicroseconds(motor_signal+delta*i/20);
      delay(10);
    }
    Serial.print("Motor signal changed to: ");
    Serial.println(motors.readMicroseconds());
  } 
  else {
    Serial.println("No arguments"); 
  }
}


