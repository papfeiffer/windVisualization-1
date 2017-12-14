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


PImage img;

Particle[] particles;
float step = 0.15;  
int particleNum = 3000;  
//maximum lifetime = 200 (declared in Particle class);


void setup() {
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
  
    float kx1 = readInterp(uwnd, (particle.xPos * uX) / width, (particle.yPos * uY) / height);
    float kx2 = readInterp(uwnd, ((particle.xPos + (step/2)) * uX) / width, ((particle.yPos + step*(kx1/2))* uY ) / height);
    float kx3 = readInterp(uwnd, ((particle.xPos + (step/2))* uX) / width, ((particle.yPos + step*(kx2/2))* uY) / height);
    float kx4 = readInterp(uwnd, ((particle.xPos + step) * uX) / width, ((particle.yPos + step*(kx3))* uY) / height);
    
    float ky1 = readInterp(vwnd, (particle.xPos * uX) / width, (particle.yPos * uY) / height);
    float ky2 = readInterp(vwnd, ((particle.xPos + (step/2)) * uX) / width, ((particle.yPos + step*(ky1/2))* uY ) / height);
    float ky3 = readInterp(vwnd, ((particle.xPos + (step/2))* uX) / width, ((particle.yPos + step*(ky2/2))* uY) / height);
    float ky4 = readInterp(vwnd, ((particle.xPos + step) * uX) / width, ((particle.yPos + (step*ky3))* uY) / height);
    
    particle.setX(particle.xPos + ((step/6)*(kx1+(2*kx2)+(2*kx3)+kx4)));
    particle.setY(particle.yPos - ((step/6)*(ky1+(2*ky2)+(2*ky3)+ky4))); //negate for processing compatibility
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
  
  int x1 = int(a);
  int x2 = x1+1;
  int y1 = int(b);
  int y2 = y1+1;

  float Q11 = readRaw(tab, x1, y1);
  float Q12 = readRaw(tab, x1, y2);
  float Q22 = readRaw(tab, x2, y2);
  float Q21 = readRaw(tab, x2, y1);

  float bilinearInterpolation = (1.0/ ((x2-x1)*(y2-y1))) * ((Q11*(x2-a)*(y2-b)) + (Q21*(a-x1)*(y2-b)) + (Q12*(x2-a)*(b-y1)) + (Q22*(a-x1)*(b-y1)));
       
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

// Reads a raw value
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