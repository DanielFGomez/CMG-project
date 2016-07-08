

//Este codigo sirve para controlar el equipo utilizando una matriz de Q-learning aprendida en simulacion
#include <VarSpeedServo.h>
#include <SerialCommand.h>
#include <SoftwareSerial.h>
#define pi 3.14159

SerialCommand SCmd; 

VarSpeedServo servo1;
VarSpeedServo servo2;
VarSpeedServo servo3;
double pos1,pos2,pos3;

VarSpeedServo motors;


int min_angle=0;
int max_angle=180;

int offset1=105;
int offset2=97;
int offset3=90;

double gimbal2servo=1;
double realspd2input=42;
double encoder_resolution=6*pi/180;

int pulses, A_SIG=0, B_SIG=1;
double velT;
double velTF;
long t,tLast;
int dt;

int angle;
int dtc=50;
double vel2dpos=180*dtc/3141.5; // pasar de radianes a grados por el tiempo de control /1000 para pasar de milli a segundos


void setup() {
    attachInterrupt(0, A_RISE, RISING);
    attachInterrupt(1, B_RISE, RISING);
    t=millis();
    tLast=millis();

    servo1.attach(8);
    servo2.attach(9);
    servo3.attach(10);
    
    servo1.write(offset1);
    servo2.write(offset2);
    servo3.write(offset3);

    pos1=offset1;
    pos2=offset2;
    pos3=offset3;
    
    motors.attach(11);
    motors.writeMicroseconds(1000);
    
    Serial.begin(9600);
         
    SCmd.addCommand("start",start); //Start motors 
    SCmd.addCommand("m",set_motors); //sets a given signal in micoseconds
    SCmd.addCommand("o1",set_offset1);
    SCmd.addCommand("o2",set_offset2);
    SCmd.addCommand("o3",set_offset3);
    SCmd.addCommand("action",action);
    SCmd.addCommand("vel",getSpd);
    SCmd.addCommand("pos",getPos);

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

void getPos(){
  Serial.println(encoder_resolution*pulses);
}

void getSpd(){
  if(millis()-t<dt){
      velTF=velT;
    }
    else{
      if(velT>0){
        velTF=1000.0/(millis()-t);
      }
      else{//Por construccion velT no puede ser 0
        velTF=-1000.0/(millis()-t);
      }
    }
  Serial.println(encoder_resolution*velTF);
}

void action(){
  double gimbalRate;  
  char *arg; 
  arg = SCmd.next();

  if (arg != NULL) 
  {
    gimbalRate=atof(arg);    // Converts a char string to an integer
   
    move_servo(&pos1,gimbalRate,servo1);
    move_servo(&pos2,gimbalRate,servo2);
    move_servo(&pos3,gimbalRate,servo3);
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

void A_RISE(){
 detachInterrupt(0);
 A_SIG=1;
 
 if(B_SIG==0){
 pulses++;//moving forward
 dt=(millis()-t);
 velT=1000.0/dt;
 }
 if(B_SIG==1){
 pulses--;//moving reverse
 dt=(millis()-t);
 velT=-1*1000.0/dt;
 }
 t=millis();
 attachInterrupt(0, A_FALL, FALLING);
}

void A_FALL(){
  detachInterrupt(0);
 A_SIG=0;
 
 if(B_SIG==1){
   pulses++;//moving forward
    dt=(millis()-t);
    velT=1000.0/dt;
 }
 if(B_SIG==0){
   pulses--;//moving reverse
   dt=(millis()-t);
   velT=-1*1000.0/dt;
 }
 t=millis();
 attachInterrupt(0, A_RISE, RISING);  
}

void B_RISE(){
 detachInterrupt(1);
 B_SIG=1;
 
 if(A_SIG==1){
   pulses++;//moving forward
   dt=(millis()-t);
   velT=1000.0/dt;
 }
 if(A_SIG==0){
   pulses--;//moving reverse
   dt=(millis()-t);
   velT=-1*1000.0/dt;
}
 t=millis();
 attachInterrupt(1, B_FALL, FALLING);
}

void B_FALL(){
 detachInterrupt(1);
 B_SIG=0;
 
 if(A_SIG==0){
   pulses++;//moving forward
    dt=(millis()-t);
    velT=1000.0/dt;
}
 if(A_SIG==1){
   pulses--;//moving reverse
   dt=(millis()-t);
   velT=-1*1000.0/dt;
}
 t=millis();
 attachInterrupt(1, B_RISE, RISING);
}
