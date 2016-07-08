int A_SIG=0, B_SIG=1;
double pos;
double resolution=6.283185/60; //2 pi sobre numero de pasos del encoder

void setup(){
  pos=0;
  
  attachInterrupt(0, A_RISE, RISING);
  attachInterrupt(1, B_RISE, RISING);
  Serial.begin(9600);
  Serial.println("t   pos");
  
}//setup


void loop(){

}

void A_RISE(){
 detachInterrupt(0);
 A_SIG=1;
 
 if(B_SIG==0)
 pos+=resolution;//moving forward
 if(B_SIG==1)
 pos-=resolution;//moving reverse
 Serial.print(millis());
 Serial.print(" ");
 Serial.println(pos);
 attachInterrupt(0, A_FALL, FALLING);
}

void A_FALL(){
  detachInterrupt(0);
 A_SIG=0;
 
 if(B_SIG==1)
 pos+=resolution;//moving forward
 if(B_SIG==0)
 pos-=resolution;//moving reverse
 Serial.print(millis());
  Serial.print(" ");
 Serial.println(pos);
 attachInterrupt(0, A_RISE, RISING);  
}

void B_RISE(){
 detachInterrupt(1);
 B_SIG=1;
 
 if(A_SIG==1)
 pos+=resolution;//moving forward
 if(A_SIG==0)
 pos-=resolution;//moving reverse
 Serial.print(millis());
  Serial.print(" ");
 Serial.println(pos);
 attachInterrupt(1, B_FALL, FALLING);
}

void B_FALL(){
 detachInterrupt(1);
 B_SIG=0;
 
 if(A_SIG==0)
 pos+=resolution;//moving forward
 if(A_SIG==1)
 pos-=resolution;//moving reverse
 Serial.print(millis());
  Serial.print(" ");
 Serial.println(pos);
 attachInterrupt(1, B_RISE, RISING);
}
