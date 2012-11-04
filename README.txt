This is my garage door controller (server side) Arduino sketch.

You need to include the 'Ethernet' and 'SPI' sub-folders where they are in relation to the
actual sketch (Garage_Door_Controller_Server.pde).




You should only need to change a few things in this sketch:

1. Line #14 - Assign it a unique IP address for YOUR network - it's defaulted 
to 192,168,0,125 (192.168.0.125) - you may need to change it to fit your network

2. Line #15 - Change this to your default gateway (usually your router's LAN IP) - 
currently it's 192,168,0,1 (192.168.0.1)

3. Line #16 - This probably won't need to be changed for most people as this is usually 
the default subnet mask set on most consumer routers - 255,255,255,0 (255.255.255.0), 
but you can change it if you need to

4. Line #18 - This is the default port that it's set to. You can change it to another port,
just remember to change it on your Android phone too.

5. Line #26 - CHANGE THIS PASSWORD. And don't forget it. You will also need to enter this in
your Android phone.

You shouldn't need to change anything else.


For more information and instructions on how to set all of this up and how everything works
together, please visit the home page of the project on my website:
http://jamienerd.blogspot.com/enter-url-here