#include <VarSpeedServo.h>
VarSpeedServo brushlessControl;
int signal;

void setup() {
  // put your setup code here, to run once:
  brushlessControl.attach(11);
  Serial.begin(115200);
  }

void loop() {
  // put your main code here, to run repeatedly:
  signal=map(analogRead(0), 0, 1023, 1000, 2000);
  brushlessControl.writeMicroseconds(signal);
  Serial.println(signal);
  delay(10);
  //El rango de analog read es 0-1024 de modo que asi me da aproximadamente el rango 1-2ms que necesito
  
  
}
