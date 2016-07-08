#include <Servo.h>

#include <SoftwareSerial.h>   // We need this even if we're not using a SoftwareSerial object
                              // Due to the way the Arduino IDE compiles
#include <SerialCommand.h>


Servo servo1;
int angle=0;
SerialCommand SCmd;   // The demo SerialCommand object


void setup()
{  
 
  servo1.attach(8);
  servo1.write(0);
  Serial.begin(9600); 

  // Setup callbacks for SerialCommand commands 
  SCmd.addCommand("servo",move_servo);  // Converts two arguments to integers and echos them back 
  SCmd.addDefaultHandler(unrecognized);  // Handler for command that isn't matched  (says "What?") 
  Serial.println("Ready"); 

}

void loop()
{  
  SCmd.readSerial();     // We don't do much, just process serial commands
}

void move_servo()    
{
  int aNumber;  
  char *arg;  
  arg = SCmd.next();
  Serial.println(arg);
  if (arg != NULL) 
  {
    aNumber=atoi(arg);    // Converts a char string to an integer
    servo1.write(aNumber);
  } 
  else {
    Serial.println("No arguments"); 
  }
}

// This gets set as the default handler, and gets called when no other command matches. 
void unrecognized()
{
  Serial.println("What?"); 
}
