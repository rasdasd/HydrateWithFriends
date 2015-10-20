import processing.serial.*;
//import http.requests.*;
Serial myPort;
int value = 0;
boolean waiting = true;
int min_thresh = 5;
int init_mass = 0;
int drink_mass = 0;
int prev_val = 0;
void setup () {
  size(800, 600);        // window size
  noLoop();
  frameRate(10);
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 57600);
  myPort.bufferUntil('\n');
  textAlign(CENTER, CENTER);
  textSize(100);
  setuptare();
  setuph();
  /*
  PostRequest post = new PostRequest("http://httprocessing.heroku.com");
   post.addData("name", "Rune");
   post.send();
   System.out.println("Reponse Content: " + post.getContent());
   System.out.println("Reponse Content-Length Header: " + post.getHeader("Content-Length"
   */
}
int tareX, tareY;      // Position of square button
int tareSize = 90;     // Diameter of tare
color tareColor;
boolean tareOver = false;
int tareTime = 0;
boolean tareFilled = false;
void setuptare()
{
  tareColor = color(0);
  tareX = width/2-tareSize-100;
  tareY = height/2-tareSize/2+150;
}
int hX, hY;      // Position of square button
int hSize = 90;     // Diameter of tare
color hColor;
color hHighlight;
boolean hOver = false;
boolean httpflag = false;
void setuph()
{
  hColor = color(255,0,0);
  hX = width/2-hSize+100;
  hY = height/2-hSize/2+150;
}
void update(int x, int y) {
  if(tareFilled && millis()>tareTime)
  {
    tareFilled = false;
    tareColor = color(0);
  }
    
if ( overRect(tareX, tareY, 2*tareSize, tareSize) ) {
    tareOver = true;
    hOver = false;
  } 
  else if(overRect(hX, hY, 2*hSize, hSize) )
  {
    tareOver = false;
    hOver = true;
  }
  else
  {
    hOver = tareOver = false;
  }
}
boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
void mousePressed() {
  if (tareOver) {
    myPort.write("T ");
    tareColor = color(200);
    tareTime = millis()+500;
    tareFilled = true;
  }
  else if(hOver)
  {
    httpflag = !httpflag;
    if(httpflag)
      hColor = color(0,255,0);
    else
      hColor = color(255,0,0);
  }
}
String final_mass_display = "";
color green = color(0,100,0);
color red = color(100,0,0);
color back = red;
int offset_value = 0;
void draw () {
  update(mouseX, mouseY);
  background(back);
  stroke(255);
  fill(tareColor);
  rect(tareX, tareY, 2*tareSize, tareSize);
  fill(255);
  textSize(50);
  text("tare",tareX+tareSize,tareY+tareSize/2-9);
  fill(hColor);
  rect(hX, hY, 2*hSize, hSize);
  fill(255);
  textSize(50);
  text("http",hX+hSize,hY+hSize/2-9);
  if(offset_value>0)
  {
    fill(color(255, 255, 255));
    text(offset_value, 400, 550); 
  }
  textSize(100);
  fill(color(255, 255, 255));
  text(value+" g", 400, 150); 
  text(final_mass_display, 400, 280);
}
int offset = 7893497;
void serialEvent (Serial myPort) {
  String inString = myPort.readString().trim();
  value = int(inString);
  if(value>1000000)
  {
    offset_value = value;
    return;
  }
  doStage();
  prev_val = value;
  redraw();
}
int drink_start = 0;
void doStage()
{
  if(abs(prev_val - value) < 2)
  {
    if (waiting)
    {
      if (value > min_thresh && value >= init_mass)
      {
        init_mass = value;
      } else if (init_mass > min_thresh && value < min_thresh)
      {
        waiting = false;
        LED(waiting);
        drink_start = millis();
      }
    } else
    {
      if (value > min_thresh)
      {
        if (value >= init_mass-min_thresh)
        {
          init_mass = value;
          waiting = true;
          LED(waiting);
        } else
        {
          drink_mass = init_mass - value;
          double drink_duration = (millis() - drink_start)/1000.0;
          process(drink_mass, drink_duration);
          reset();
        }
      }
    }
  }
}
void process(int water_mass, double drink_duration)
{
  final_mass_display = Integer.toString(water_mass)+"g  " + String.format("%.1f",drink_duration)+"s";
}
void reset()
{
  init_mass = 0;
  drink_mass = 0;
  waiting = true;
  LED(waiting);
}
void LED(boolean waiting)
{
  if(waiting)
  {
    myPort.write("W ");
    back = red;
  }
  else
  {
    myPort.write("D ");
    back = green;
  }
}