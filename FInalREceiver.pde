import nl.tue.id.oocsi.*;
import java.util.*;
import java.io.FileWriter;
import java.io.*;
import grafica.*;

String[] kString = new String[] { "",""  };
OOCSIEvent message;
public GPlot plot;
public PShape star;
int s = second();
int m = minute(); 
int mO = minute(); 
int h = hour(); 
int hO = hour(); //problem
int ylog = 65;
int count = 1;
int day = day();
int month = month();
int year = year();
PrintWriter output;
OOCSI send = new OOCSI(this, "SendF", "oocsi.id.tue.nl");

void setup() {
  size(1000, 500);
  background(255);
  textSize(20);
  fill(0);
  text("log", 800, 40);
  
   String date = day + "." + month + "." + year;

   output = createWriter("log_" + date + ".txt");
 

  // connect to OOCSI server running on the same machine (localhost)
  // with "receiverName" to be my channel others can send data to
  // (for more information how to run an OOCSI server refer to: https://iddi.github.io/oocsi/)
  OOCSI oocsi = new OOCSI(this, "rec_sz", "oocsi.id.tue.nl");
  
  

  // subscribe to channel "testchannel"
  // either the channel name is used for looking for a handler method...
  oocsi.subscribe("DS");
  send.subscribe("testchannel");
  // ... or the handler method name can be given explicitly
  // oocsi.subscribe("testchannel", "testchannel");
  
  // Create a new plot and set its position on the screen
  plot = new GPlot(this);
  // or all in one go
  // GPlot plot = new GPlot(this, 25, 25);
  plot.setPos(25, 25);
  plot.setDim(300, 300);

  // Set the plot title and the axis labels
  plot.setTitleText("Usage time for paper roll");
  plot.getXAxis().setAxisLabelText("time");
  plot.getYAxis().setAxisLabelText("messages");
  plot.activateZooming(100);

  star = loadShape("star.svg");
  star.disableStyle();

  noLoop();
}


void draw() {

  timelog();
  
}

void DS(OOCSIEvent message) {

  // get and save string value
  kString = message.keys();

  // display what we receive in terminal and separate the keys
  allKeys(kString, message); 
    
}

void allKeys(String[] s, OOCSIEvent msg){
    
  for (int i = 0; i <= s.length-1; i++){
    String k = msg.getString(s[i], "m"); //to read the message value, a string getter
    println("key number: " + i + " and key name: " + s[i] );
    print(k);
    println("");
    count++;
    draw();
 } 
} 

void timelog(){ 
   m = minute(); 
   h = hour(); 
   s = second();
   
   triggered();
   
   int dif = abs(hO-h);
   
   if( dif >= 1){
     count = 1;
     hO = h;
   } 
   
    text(h + ": ", 800, ylog);
    text(m + ": ", 830, ylog);
    text(s + " h", 860, ylog);
    ylog = ylog + 10;
   // print("hour: " + h + " min: " + m + "seconds: " +s );
    
    //writing to file
    output.println(str(h) + " : " +  str(m) + " : " + str(s) + " h");
    output.flush();  
  
  // Add a new point to the plot
  plot.addPoint(h, count); 

  
  plot.beginDraw();
  plot.drawBackground();
  plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTitle();
  plot.drawGridLines(GPlot.BOTH);
  plot.drawLines();
  plot.drawPoints(star);
  plot.endDraw();
  
  redraw();

}

void triggered(){
  String StringMin = Integer.toString(m);
  boolean allow = false; // debug - 2 different cases -  if at start - odd num;
  int triggerMsg = 0;
 // boolean start = true;
  
  int minS = minute();
  int diffM = abs(mO - minS);
  
 //  allow = StringMin.endsWith("5");
   
   
   if( diffM >= 1){
     allow = true;
     mO = m;
   } 
   
   
   if((StringMin.endsWith("5") || StringMin.endsWith("3") || StringMin.endsWith("9") || StringMin.endsWith("7") || StringMin.endsWith("1")) && allow ){ // &&!start
     allow = false;
     triggerMsg = 1;
     send.channel("testchannel")
    // integer type number
    .data("triggerMsg", triggerMsg)
  
    // send all
    .send();
    return; 
   }
   
  /* if((StringMin.endsWith("5") || StringMin.endsWith("3") || StringMin.endsWith("9") || StringMin.endsWith("7") || StringMin.endsWith("1")) && start){
     start = false;
     allow = true;   
     triggerMsg = 1;
     send.channel("testchannel")
    // integer type number
    .data("triggerMsg", triggerMsg)
    // send all
    .send();
    return; 
   } */
  
}
