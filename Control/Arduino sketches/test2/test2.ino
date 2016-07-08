

//Este codigo sirve para comparar el movimiento del prototipo con el del modelo computacional

//Tiene varias rutinas predefinidas
//1. Mueve el servo 1
//2. Se inclina en roll
//3. Gira en yaw
//4. Se inclina y vuelve en el eje de cada volante
//Permite controlar la posicion de los servos con un potenciometro

int offset1=115;
int offset2=97;
int offset3=90;

double gimbalRate=0.5;



#include <VarSpeedServo.h>
#include <SerialCommand.h>
#include <SoftwareSerial.h> 

SerialCommand SCmd; 

VarSpeedServo servo1;
VarSpeedServo servo2;
VarSpeedServo servo3;

VarSpeedServo motors;

double servo2gimbal=1;
double realspd2input=42;

int angle;

void setup() {
  
    servo1.attach(8);
    servo2.attach(9);
    servo3.attach(10);
    
    servo1.write(offset1);
    servo2.write(offset2);
    servo3.write(offset3);
    
    motors.attach(11);
    motors.writeMicroseconds(1000);
    
    Serial.begin(9600);
     
    SCmd.addCommand("start",start); //Start motors 
    SCmd.addCommand("m",set_motors); //sets a given signal in micoseconds
    SCmd.addCommand("1",move_gimbal1);
    SCmd.addCommand("2",roll);
    SCmd.addCommand("3",yaw);
    SCmd.addCommand("4",roll3);
    SCmd.addCommand("o1",set_offset1);
    SCmd.addCommand("o2",set_offset2);
    SCmd.addCommand("o3",set_offset3);
}

void loop() {
  // put your main code here, to run repeatedly:
    SCmd.readSerial();
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

void move_gimbal1()
{
  Serial.println("Moving gimbal 1");
  servo1.write(0,gimbalRate*realspd2input);
  delay(5000);
  servo1.write(offset1,gimbalRate*realspd2input);  
}

void roll()
{
  Serial.println("They see rollin...");
  servo2.write(offset2-57,gimbalRate*realspd2input,false);
  servo3.write(offset3+57,gimbalRate*realspd2input,true);
  
  delay(5000);
  Serial.println("...they hatin");
  servo2.write(offset2,gimbalRate*realspd2input,false);
  servo3.write(offset3,gimbalRate*realspd2input,true);
}

void yaw()
{
  Serial.println("Yawing meneuver initiated");
  
  servo1.write(offset1-57,gimbalRate*realspd2input,false);
  servo2.write(offset2-57,gimbalRate*realspd2input,false);
  servo3.write(offset3-57,gimbalRate*realspd2input,true);

  delay(2000);
  servo1.write(offset1,gimbalRate*realspd2input,false);
  servo2.write(offset2,gimbalRate*realspd2input,false);
  servo3.write(offset3,gimbalRate*realspd2input,true);
}

void roll3()
{
  //axis 1
  Serial.println("They see rollin...");
  servo2.write(offset2-20,gimbalRate*realspd2input,false);
  servo3.write(offset3+20,gimbalRate*realspd2input,true);
  
  Serial.println("...they hatin");
  servo2.write(offset2,gimbalRate*realspd2input,false);
  servo3.write(offset3,gimbalRate*realspd2input,true);

  //axis 2
  servo3.write(offset3-20,gimbalRate*realspd2input,false);
  servo1.write(offset1+20,gimbalRate*realspd2input,true);
  
  servo3.write(offset3,gimbalRate*realspd2input,false);
  servo1.write(offset1,gimbalRate*realspd2input,true);

  //axis3
  servo1.write(offset1-20,gimbalRate*realspd2input,false);
  servo2.write(offset2+20,gimbalRate*realspd2input,true);
  
  servo1.write(offset1,gimbalRate*realspd2input,false);
  servo2.write(offset2,gimbalRate*realspd2input,true);
}


void set_offset1(){
  char *arg; 
  arg = SCmd.next();
  if (arg != NULL) 
  {
    offset1=atoi(arg);    // Converts a char string to an integer
    Serial.print("Changing servo 1 offset to: ");
    Serial.println(offset1);
    servo1.write(offset1,30);
  } 
  else {
    Serial.println("No arguments"); 
  }
}

void set_offset2(){
  char *arg; 
  arg = SCmd.next();
  if (arg != NULL) 
  {
    offset2=atoi(arg);    // Converts a char string to an integer
    Serial.print("Changing servo 2 offset to: ");
    Serial.println(offset2);
    servo2.write(offset2,30);
  } 
  else {
    Serial.println("No arguments"); 
  }
}

void set_offset3(){
  char *arg; 
  arg = SCmd.next();
  if (arg != NULL) 
  {
    offset3=atoi(arg);    // Converts a char string to an integer
    Serial.print("Changing servo 3 offset to: ");
    Serial.println(offset3);
    servo3.write(offset3,30);
  } 
  else {
    Serial.println("No arguments"); 
  }
}

