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
double resolution=2*3.1415/60.0;
int pulses, A_SIG=0, B_SIG=1;
double velT;
double velTF;
long t,tLast;
int dt;
int ct=500;
double vel2dpos=180*ct*3141.5;
double realspd2input=48;

int offset1=115;
int offset2=97;
int offset3=90;


void setup(){
  attachInterrupt(0, A_RISE, RISING);
  attachInterrupt(1, B_RISE, RISING);
  t=millis();
  tLast=millis();
  Serial.begin(9600);

  servo1.attach(8);
  servo2.attach(9);
  servo3.attach(10);
    
  servo1.write(of);
  servo2.write(90*servo2gimbal);
  servo3.write(90*servo2gimbal);
    
  motors.attach(11);
  motors.writeMicroseconds(1000);

  SCmd.addCommand("getSpd",getSpd);
  SCmd.addCommand("action",action);
  
}//setup


void loop(){
  SCmd.readSerial(); 
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
  Serial.prinln(resolution*velTF);
}

void action(){
  
  theta=theta+vel*vel2dpos;  
  
  if (theta>max_angle){
    theta=max_angle;
  }
  if (theta<min_angle){
    theta=min_angle;
  }
  //For debugging purposes
  //Serial.print(vel*vel2dpos);
  //Serial.print(" ");
  //Serial.println(theta);
  if (vel<0){
    
    servo.write(theta*gimbal2servo,-1.0*vel*realspd2input,false); 
  }
  else if(vel>0){
    servo.write(theta*gimbal2servo,vel*realspd2input,false);
  }
  else if(vel==0){
    servo.write(theta*gimbal2servo,0,false);
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
