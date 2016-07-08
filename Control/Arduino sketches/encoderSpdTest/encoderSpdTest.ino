
int pulses, A_SIG=0, B_SIG=1;
double velT;
double velF;
double velTF;
long t,tLast;
int dt;
int ct=500;
void setup(){

  
  attachInterrupt(0, A_RISE, RISING);
  attachInterrupt(1, B_RISE, RISING);
  t=millis();
  tLast=millis();
  Serial.begin(9600);
  
}//setup


void loop(){
  
  
  if(millis()-tLast>ct){
    
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
    
    velF=(1000*pulses/ct);
    pulses=0;
    tLast=millis();
    Serial.print("Vel Period=");
    Serial.print(velT);
    Serial.print("   Vel Frequency=");
    Serial.print(velF);
    Serial.print("   Vel Mixed=");
    Serial.println(velTF);
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

