#include <SPI.h>
#include <Ethernet.h>

/*
UPGRADES / TODOs:

1. Email someone when this is used
ORRRRR
2. Write a log to the SD Card (much faster)

*/

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,0, 125 }; // Ip address to assign to this 'server' (ip that it listens on)
byte gateway[] = { 192,168,0, 1 }; // Gateway ip
byte subnet[] = { 255, 255, 255, 0 }; // Subnet mask

Server server(4999); // port that it listens on

//boolean gotAMessage = false; // whether or not you got a message from the client yet
boolean isAuthenticated = false;

String myLittleBuffer = "";

// This is the password needed to connect
String myPass = "passwordhere"; // *** Any string comparisons to Android commands must be declared up here as Strings !!! ***

// The below is obsolete...delete it
String cmdGarageDoorStatusRequest = "cmd=statusRequest";

// The command we listen for to open/close the garage door
String cmdGarageDoorToggle = "cmd=gdToggle";

// The command we listen for to 'crack' the garage door
String cmdGarageDoorCrack = "cmd=gdCrack"; // Note that this will not include the milliseconds to pause for the crack obviously

// The command we listen for sent from the client for an explicit disconnect
String disconnect = "disconnect";

// Character holder to build up command 'strings' sent from the client
char thisChar = 'A';

// The state of the garage door - 0/LOW=open, 1/HIGH=closed (yes, this is logically backwards)
int garage_door_state = 0;
//int milsToPauseForCrack = 0;

#define RELAY 9    // the pin for the RELAY
// Uncomment the below line to use an LED as an indication when the garage door button is virtually pushed (Line 1 of 6)
//#define LEDNOTIFY 8    // the LED that blinks when the garage door is opened or closed
#define BUTTON 7  // the input pin where the
                  // reed/magnetic switch is connected
                  // to detect if the garage door is closed/open


void setup() {
  // initialize the ethernet device
  Ethernet.begin(mac, ip, gateway, subnet);
  // start listening for clients
  server.begin();
  // open the serial port
  Serial.begin(9600);
  
  pinMode(RELAY, OUTPUT);    // tell Arduino RELAY is an output
  // Uncomment the below line to use an LED as an indication when the garage door button is virtually pushed (Line 2 of 6)
  //pinMode(LEDNOTIFY, OUTPUT);  // tell Arduino LEDNOTIFY is an output
  pinMode(BUTTON, INPUT);  // and BUTTON is an input
}

void loop() {
  // wait for a new client:
  Client client = server.available();

  // when the client sends the first byte, say hello:
  if (client) {

    if (!isAuthenticated) {
      thisChar = client.read();
    }
    
    // A '*' character is sent at the end of the password to signifiy 'end-of-line' so to speak
    if (thisChar == '*') {
      
      // If what's in the buffer is the correct password...
      if (myLittleBuffer.equals(myPass)) {
        // Correct password, continue on
        Serial.println(myLittleBuffer);
        Serial.println("correct password!");



        // get the initial status of the garage door, send the status to the client
        garage_door_state = digitalRead(BUTTON);
        if (garage_door_state == HIGH) {
          server.println("status:closed"); // Send the initial garage door status
          Serial.println("Sent: status:closed");
        } else {
          server.println("status:open"); // Send the initial garage door status
          Serial.println("Sent: status:open");
        }
        

        myLittleBuffer = ""; // Make sure that this string starts out empty
        client.flush(); // Flush any garbage characters out
        Serial.println(thisChar);
        
        
        // Now start our real loop (while the client is connected)
        do
        {
          
          // THE EVERY OTHER CHARACTER PROBLEM IS CAUSED BY THE BELOW IF STATEMENT!
          //if (client.read() != (char)-1) {
            
            // Read in any character that comes in
            thisChar = client.read();
            
          //} 
          
           //Serial.print("thisChar = " + thisChar);
           Serial.println("myLittleBuffer = " + myLittleBuffer + ", thisChar = " + thisChar);
          
          // Check for the '@' character as it is the 'command' end-of-line signal so to speak
          if (thisChar == '@') {
            
            // *** THIS IS THE MAIN BLOCK OF CODE THAT ACTUALLY DOES STUFF HERE ***
            if (myLittleBuffer.equals(cmdGarageDoorStatusRequest)) {
              // TODO - Respond to Garage Door Status Request
              Serial.println("Garage Door Status Request Block:");
              Serial.println(myLittleBuffer);
            } else if (myLittleBuffer.equals(cmdGarageDoorToggle)) {
              // Respond to Garage Door Toggle Command
              Serial.println("Garage Door Toggle Command Block:");
              Serial.println(myLittleBuffer);
              
              digitalWrite(RELAY, HIGH); // 'Push the button'
              // Uncomment the below line to use an LED as an indication when the garage door button is virtually pushed (Line 3 of 6)
              //digitalWrite(LEDNOTIFY, HIGH);  // turn the LED on
              delay(250); // Wait 1/4 second
              digitalWrite(RELAY, LOW); // 'Release the button'
              // Uncomment the below line to use an LED as an indication when the garage door button is virtually pushed (Line 4 of 6)
              //digitalWrite(LEDNOTIFY, LOW);  // turn the LED off
            } else if (myLittleBuffer.substring(6,9) == "Cra") {
              // We can't examine the entire string as we do for the other possible received commands as this can contain virtually anything
              //  because the length in milliseconds gets sent immediately after the actual command, and of course we can't predict this
              
              // Respond to Garage Door Crack Command
              Serial.println("Garage Door Crack Command Block:");
              Serial.println(myLittleBuffer);
              
              int lengthOfMLB;
              int posOfColon;
              String milsToPauseForCrack = "";
              
              lengthOfMLB = myLittleBuffer.length();
              posOfColon = myLittleBuffer.indexOf(":");
              
              posOfColon++; // We actually need to start at the very next character after the colon, because we don't care about the colon
              // The following three lines builds up a string that contains the number of milliseconds to pause between button-presses
              for (int i=posOfColon; i <= lengthOfMLB; i++){
                milsToPauseForCrack = milsToPauseForCrack + myLittleBuffer.charAt(i);
              }
              Serial.println("milsToPauseForCrack: " + milsToPauseForCrack);
              
              long x = stringToLong(milsToPauseForCrack); // Now convert that string to a number
              
              digitalWrite(RELAY, HIGH); // 'Push the button'
              // Uncomment the below line to use an LED as an indication when the garage door button is virtually pushed (Line 5 of 6)
              //digitalWrite(LEDNOTIFY, HIGH);  // turn the LED on
              delay(100); // Wait 1/10 second
              digitalWrite(RELAY, LOW); // 'Release the button'
              
              delay(x); // Wait for USER-SPECIFIED amount of milliseconds
              
              digitalWrite(RELAY, HIGH); // 'Push the button'
              delay(100); // Wait 1/10 second
              digitalWrite(RELAY, LOW); // 'Release the button'
              // Uncomment the below line to use an LED as an indication when the garage door button is virtually pushed (Line 6 of 6)
              //digitalWrite(LEDNOTIFY, LOW);  // turn the LED off
              
            } else if (myLittleBuffer.equals(disconnect)) {
              // If the disconnect command was received, disconnect properly
              Serial.println("Disconnect Block:");
              Serial.println(myLittleBuffer);
              // TODO - Respond to Disconnect
              myLittleBuffer = ""; // Reset this for the next connection
              client.stop();
              break; // This is to get us out of the loop so we don't try and send one last garage door status
            }
            // *** THIS IS THE MAIN BLOCK OF CODE THAT ACTUALLY DOES STUFF HERE ***
          
          // Reset our 'buffer' back to empty because we received the special '*' character to denote end-of-command
          myLittleBuffer = "";
            
          } else {
            // We want to ignore '*', '@', and CR/LF
            if (thisChar != '*' && thisChar != (char)-1 && thisChar != '@' && thisChar != (char)13 && thisChar != (char)10) {
              myLittleBuffer = String(myLittleBuffer + thisChar);
            }
          }


          // Send the current status of the garage door to the client
          // Maybe in the future we should change the below code so that it doesn't send the status
          //  constantly - only when it changes state...this would help reduce traffic/communication
          garage_door_state = digitalRead(BUTTON);
          if (garage_door_state == HIGH) {
            server.println("status:closed");
            Serial.println("Sent: status:closed");
          } else {
            server.println("status:open");
            Serial.println("Sent: status:open");
          }
          
          // This is good for watching the commands come/go
          // Comment out when in production
          //delay(1000); // Wait some time so that we can read what's in the serial monitor
          
        } while (client); // while the client is connected
        
      } else {
          Serial.print(myLittleBuffer);
          Serial.print("incorrect password");
          server.println("incorrect password"); // Send an incorrect password message if the password doesn't match
          myLittleBuffer = ""; // Reset myLittleBuffer for next time
          client.flush(); // Flush out any remaining characters
          client.stop(); // disconnect client
      }
      
      // Reset our 'buffer' back to empty because we received the special '*' character to denote end-of-command
      //myLittleBuffer = "";
      
    } else {
     
      myLittleBuffer = String(myLittleBuffer + thisChar);
      
    }
  
  }

}


long stringToLong(String s)
{
    char arr[12];
    s.toCharArray(arr, sizeof(arr));
    return atol(arr);
} 
