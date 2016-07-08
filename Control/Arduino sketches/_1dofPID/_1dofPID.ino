#include <PID_v1.h>
#include <VarSpeedServo.h>
#include <SerialCommand.h>
#include <SoftwareSerial.h> 
#define pi 3.14159
//La idea es modificar los angulos y las velocidades de modo que el PID trabaje con unidades fisicas

//Inicializo el objeto para enviar comandos
SerialCommand SCmd; 

//Inicializo PID
double Setpoint, Input, Output;
double target=0;
boolean sine=false;
long sine_t=0;
double sine_period=20;
PID myPID(&Input, &Output, &Setpoint,0.2038,0,0.4076, REVERSE);


//Inicializo necesario para el encoder
int pulses, A_SIG=0, B_SIG=1;



//Inicializo servos
VarSpeedServo servo1;
VarSpeedServo servo2;
VarSpeedServo servo3;
double pos1,pos2,pos3;
unsigned long previous_millis=0; //Necesario para regular la frecuencia de control de servos

int min_angle=0;
int max_angle=180;

//Inicializo motores
VarSpeedServo motors;
int brushlessInput=1000; //Input inicial en microsegundos


//
double encoderResolution=6*3.14/180;
double realspd2input=42;
double gimbal2servo=1;//Relacion entre engranajes

int offset1=115;
int offset2=97;
int offset3=90;


int dtc=50;
double vel2dpos=180*dtc/3141.5; // pasar de radianes a grados por el tiempo de control /1000 para pasar de milli a segundos


void setup(){

  //Inicializa posiciones de los servos
  servo1.attach(8);
  servo2.attach(9);
  servo3.attach(10);
     
  servo1.write(offset1);
  servo2.write(offset2);
  servo3.write(offset3);

  pos1=offset1;
  pos2=offset2;
  pos3=offset3;

  //Inicializa el controlador de los motores brushless
  motors.attach(11);
  motors.writeMicroseconds(1000);

 //Inicialliza la comunicacion y los comandos
   Serial.begin(9600);
   SCmd.addCommand("start",start); //Start motors 
   SCmd.addCommand("m",set_motors); //sets a given signal in micoseconds
   SCmd.addCommand("o1",set_offset1);
   SCmd.addCommand("o2",set_offset2);
   SCmd.addCommand("o3",set_offset3);
   SCmd.addCommand("target",set_target);
   SCmd.addCommand("test",test_sequence);
   SCmd.addCommand("sine",sine_test);
  
  //Inicializa los interrupts que necesita el encoder
  attachInterrupt(0, A_RISE, RISING); //Esto pone un interrupt en el pin 2, se usa para leer el encoder
  attachInterrupt(1, B_RISE, RISING); //Esto pone un interrupt en el pin 3, se usa para leer el encoder
 

  

  Setpoint = 0;

  //turn the PID on
  myPID.SetOutputLimits(-1,1);
  myPID.SetSampleTime(50);
  myPID.SetMode(AUTOMATIC);

  
  Serial.println("Time, input, target, output");
  
}//setup


void loop(){

  if(sine){
    target=sin(2*pi*(millis()-sine_t)/(sine_period*1000));
  }
  
  SCmd.readSerial(); 

  Input = pulses*encoderResolution-target;
  myPID.Compute();

  if(millis()-previous_millis>dtc){
    previous_millis=millis();
    
    move_servo(&pos1,Output,servo1);
    move_servo(&pos2,Output,servo2);
    move_servo(&pos3,Output,servo3);
  }
  if(millis()%10==0){
    Serial.print(millis());
    Serial.print(", ");
    Serial.print(pulses*encoderResolution*180/3.1415);
    Serial.print(", ");
    Serial.print(target*180/3.14);
    Serial.print(", ");
    Serial.println(Output);
  }
  
 
}

void A_RISE(){
 detachInterrupt(0);
 A_SIG=1;
 
 if(B_SIG==0)
 pulses++;//moving forward
 if(B_SIG==1)
 pulses--;//moving reverse
 attachInterrupt(0, A_FALL, FALLING);
}

void A_FALL(){
  detachInterrupt(0);
 A_SIG=0;
 
 if(B_SIG==1)
 pulses++;//moving forward
 if(B_SIG==0)
 pulses--;//moving reverse
 attachInterrupt(0, A_RISE, RISING);  
}

void B_RISE(){
 detachInterrupt(1);
 B_SIG=1;
 
 if(A_SIG==1)
 pulses++;//moving forward
 if(A_SIG==0)
 pulses--;//moving reverse
 attachInterrupt(1, B_FALL, FALLING);
}

void B_FALL(){
 detachInterrupt(1);
 B_SIG=0;
 
 if(A_SIG==0)
 pulses++;//moving forward
 if(A_SIG==1)
 pulses--;//moving reverse
 attachInterrupt(1, B_RISE, RISING);
}

void start(){
    Serial.println("Starting motors");
    int i;
    for (i=1000;i<=1050;i++){
      motors.writeMicroseconds(i);
      delay(10);
    }
    Serial.println("Motors on");
    brushlessInput=1050;
}

void set_motors(){  
  char *arg; 
  arg = SCmd.next(); 
  if (arg != NULL) 
  {
    brushlessInput=atoi(arg);    // Converts a char string to an integer
    Serial.println(brushlessInput);
    motors.writeMicroseconds(brushlessInput);
  } 
  else {
    Serial.println("No arguments"); 
  }
}

void move_servo(double *pos, double vel, VarSpeedServo servo){
  *pos=*pos+vel*vel2dpos;  
  
  if (*pos>max_angle){
    *pos=max_angle;
  }
  if (*pos<min_angle){
    *pos=min_angle;
  }
  //For debugging purposes
  //Serial.print(vel*vel2dpos);
  //Serial.print(" ");
  //Serial.println(*pos);
  if (vel<0){
    
    servo.write(*pos*gimbal2servo,-1.0*vel*realspd2input,false); 
  }
  else if(vel>0){
    servo.write(*pos*gimbal2servo,vel*realspd2input,false);
  }
  else if(vel==0){
    servo.write(*pos*gimbal2servo,0,false);
  }
}

void set_target()//Target in degrees
{
  char *arg; 
  arg = SCmd.next(); 
  if (arg != NULL) 
  {
    target=3.1415/180*atoi(arg);    // Converts a char string to an integer
    Serial.print("Target set to: ");
    Serial.println(target);
  } 
  else {
    Serial.println("No arguments"); 
  }
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

void test_sequence(){
  start();
  delay(4000);
  brushlessInput=1100;    // Converts a char string to an integer
  Serial.println(brushlessInput);
  motors.writeMicroseconds(brushlessInput);
  delay(3000);
  Serial.println("XXXXXXXXXXXXXXXXXXX     Beginning control to turn 90°     XXXXXXXXXXXXXXXXXXXXXXX");
  target=3.14/2;
  Serial.println("Time, input, target, output");
  
}

void sine_test(){
  start();
  delay(4000);
  brushlessInput=1100;    // Converts a char string to an integer
  Serial.println(brushlessInput);
  motors.writeMicroseconds(brushlessInput);
  delay(3000);
  Serial.println("XXXXXXXXXXXXXXXXXXX     Beginning control to turn 90°     XXXXXXXXXXXXXXXXXXXXXXX");
  sine=true;
  sine_t=millis();
  Serial.println("Time, input, target, output");
  
}

