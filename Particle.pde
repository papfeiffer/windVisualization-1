
class Particle {
  
  float xPos = random(700); 
  float yPos = random(400);
  float lifetime = random(200);
  
  Particle() {    
    
  }
  
  void setX(float newPos) {   
    xPos = newPos;   
  }
  
  void setY(float newPos) {
    yPos = newPos;
  }
  
  void decreaseLifetime() {
    lifetime--;
  }
  
  void newLifetime() {
    lifetime = random(200);
  }
  
  void display() {
    strokeWeight(4);
    beginShape(POINTS);
    vertex(xPos, yPos);
    endShape();
  }
  
  
  
  
}