// uwnd stores the 'u' component of the wind.
// The 'u' component is the east-west component of the wind.
// Positive values indicate eastward wind, and negative
// values indicate westward wind.  This is measured
// in meters per second.
Table uwnd;

// vwnd stores the 'v' component of the wind, which measures the
// north-south component of the wind.  Positive values indicate
// northward wind, and negative values indicate southward wind.
Table vwnd;

// An image to use for the background.  The image I provide is a
// modified version of this wikipedia image:
//https://commons.wikimedia.org/wiki/File:Equirectangular_projection_SW.jpg
// If you want to use your own image, you should take an equirectangular
// map and pick out the subset that corresponds to the range from
// 135W to 65W, and from 55N to 25N
PImage img;

Particle[] particles;
float step = 0.15;  
int particleNum = 3000;  
//maximum lifetime = 200 (declared in Particle class);


void setup() {
  // If this doesn't work on your computer, you can remove the 'P3D'
  // parameter.  On many computers, having P3D should make it run faster
  size(700, 400, P3D);
  pixelDensity(displayDensity());
  
  img = loadImage("background.png");
  uwnd = loadTable("uwnd.csv");
  vwnd = loadTable("vwnd.csv");
   
  particles = new Particle[particleNum];  
  createParticles();
    
}


void draw() {
  background(255);
  image(img, 0, 0, width, height);
  drawMouseLine();
  
  //fit points onto screen
  float uX = uwnd.getColumnCount(); //561, vwnd has same size
  float uY = uwnd.getRowCount();  //240, vwnd has same size
  for (Particle particle: particles) {
    
    //Euler Integration Start-------------------------------------------------
     
    //float dx = readInterp(uwnd, (particle.xPos * uX) / width, (particle.yPos * uY) / height);
    //float dy = -readInterp(vwnd, (particle.xPos * uX) / width, (particle.yPos * uY) / height); 
    
    //particle.setX(particle.xPos + (step*dx));
    //particle.setY(particle.yPos + (step*dy));
    
   //Euler Integration End --------------------------------------------------------------------  
   
     
   //Runge-Kutta Start ----------------------------------------------
  
    float k1x = readInterp(uwnd, (particle.xPos * uX) / width, (particle.yPos * uY) / height);
    float k2x = readInterp(uwnd, ((particle.xPos + (step/2)) * uX) / width, ((particle.yPos + step*(k1x/2))* uY ) / height);
    float k3x = readInterp(uwnd, ((particle.xPos + (step/2))* uX) / width, ((particle.yPos + step*(k2x/2))* uY) / height);
    float k4x = readInterp(uwnd, ((particle.xPos + step) * uX) / width, ((particle.yPos + step*(k3x))* uY) / height);
    
    float k1y = readInterp(vwnd, (particle.xPos * uX) / width, (particle.yPos * uY) / height);
    float k2y = readInterp(vwnd, ((particle.xPos + (step/2)) * uX) / width, ((particle.yPos + step*(k1y/2))* uY ) / height);
    float k3y = readInterp(vwnd, ((particle.xPos + (step/2))* uX) / width, ((particle.yPos + step*(k2y/2))* uY) / height);
    float k4y = readInterp(vwnd, ((particle.xPos + step) * uX) / width, ((particle.yPos + (step*k3y))* uY) / height);
    
    particle.setX(particle.xPos + ((step/6)*(k1x+(2*k2x)+(2*k3x)+k4x)));
    particle.setY(particle.yPos - ((step/6)*(k1y+(2*k2y)+(2*k3y)+k4y)));
    //Runge-Kutta End ------------------------------------
    
    
    //when particle dies -----------------------------------------------
    if (particle.lifetime <= 0) {
      particle.reset();
    }
    
    particle.display();  
    particle.decreaseLifetime();
  }
  
}


// Reads a bilinearly-interpolated value at the given a and b
// coordinates.  Both a and b should be in data coordinates.
float readInterp(Table tab, float a, float b) {
  //tab = u component or v component
  //grid units
  
  //original values
  float x = a;
  float y = b;
  
  //bilinear interpolation
  int x1 = int(a);
  int x2 = x1+1;
  int y1 = int(b);
  int y2 = y1+1;

  // 2D array
  //return readRaw(tab, x, y);
  float Q11 = readRaw(tab, x1, y1);
  float Q12 = readRaw(tab, x1, y2);
  float Q22 = readRaw(tab, x2, y2);
  float Q21 = readRaw(tab, x2, y1);

  float bilinearInterpolation = (1.0/ ((x2-x1)*(y2-y1))) 
       * ((Q11*(x2-x)*(y2-y)) + (Q21*(x-x1)*(y2-y)) + (Q12*(x2-x)*(y-y1)) + (Q22*(x-x1)*(y-y1)));
  return bilinearInterpolation;
}

void createParticles() {
  for(int i = 0; i < particleNum; i++) {
    Particle particle = new Particle();
    particles[i] = particle;
  }  
}

void drawMouseLine() {
  // Convert from pixel coordinates into coordinates
  // corresponding to the data.
  float a = mouseX * uwnd.getColumnCount() / width;
  float b = mouseY * uwnd.getRowCount() / height;
  
  // Since a positive 'v' value indicates north, we need to
  // negate it so that it works in the same coordinates as Processing
  // does.
  float dx = readInterp(uwnd, a, b) * 10;
  float dy = -readInterp(vwnd, a, b) * 10;
  line(mouseX, mouseY, mouseX + dx, mouseY + dy);
}

// Reads a raw value (bret's code. does not need to be changed)
float readRaw(Table tab, int x, int y) {
  if (x < 0) {
    x = 0;
  }
  if (x >= tab.getColumnCount()) {
    x = tab.getColumnCount() - 1;
  }
  if (y < 0) {
    y = 0;
  }
  if (y >= tab.getRowCount()) {
    y = tab.getRowCount() - 1;
  }
  return tab.getFloat(y,x);
}