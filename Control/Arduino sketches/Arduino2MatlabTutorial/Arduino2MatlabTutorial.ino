void setup() {
  Serial.begin(9600);
    // put your main code here, to run repeatedly:
  Serial.println('a');
  char a='b';
  while(a!='a')
  {
    
    a=Serial.read();
    
  }
  Serial.println("ok");
}

void loop() {

}
