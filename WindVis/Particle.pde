
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
  
  void display() {
    strokeWeight(3);
    beginShape(POINTS);
    vertex(xPos, yPos);
    endShape();
  }
  
  void reset() {
    xPos = random(700);
    yPos = random(400);
    lifetime = random(200);
  }
  
  
}