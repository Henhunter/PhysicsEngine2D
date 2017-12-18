//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//    

//the core class that takes care of all interactions between PhysicsObjects
public class PhysicsEngine
{  
  ArrayList<PhysicsObject> objectArray = new ArrayList<PhysicsObject>();

  //Checks borderCollisions for our objects
  void borderCollision()
  {
    for (int i = 0; i<objectArray.size(); i++)
    {

      PhysicsObject PO = objectArray.get(i);
      if (PO.constrainedInFrame) {
        if (PO instanceof Circle)
          borderCollisionCircle(PO);
        if (PO instanceof Rect)
          borderCollisionRect(PO);
      }
    }
  }

  //These two methods adds and removes PhysicsObjects that needs to be checked.
  void add(PhysicsObject PO) {
    objectArray.add(PO);
  }
  void remove(PhysicsObject PO) {
    objectArray.remove(PO);
  }

  //Bordercollision for circle, also makes sure that the object is going the right way after impact by forcing the right direction.  
  void borderCollisionCircle(PhysicsObject PO)
  {
    Circle circle = (Circle)PO;

    if (circle.pos.x <= circle.radius)
    {
      circle.velocity.x = Math.abs(circle.velocity.x); //math.abs will make any number positive
    } else if (circle.pos.x >= width-(circle.radius))
    {
      circle.velocity.x = -Math.abs(circle.velocity.x);
    }
    if (circle.pos.y <= circle.radius)
    {
      circle.velocity.y = Math.abs(circle.velocity.y);
    } else if (circle.pos.y >= height-(circle.radius)) {
      circle.velocity.y = -Math.abs(circle.velocity.y);
    }
  }

  //Bordercollision for rectangle, also makes sure that the object is going the right way after impact by forcing the right direction. 
  void borderCollisionRect(PhysicsObject PO)
  {

    Rect rect = (Rect)PO;

    if (rect.pos.x <= 0 )
    {
      rect.velocity.x = Math.abs(rect.velocity.x);
    } else if (rect.pos.x >= width-(rect.w)) {
      rect.velocity.x = -Math.abs(rect.velocity.x);
    }
    if ( rect.pos.y <= 0 )
    {
      rect.velocity.y = Math.abs(rect.velocity.y);
    } else if (rect.pos.y >= height-(rect.h)) {
      rect.velocity.y = -Math.abs(rect.velocity.y);
    }
  }

  //returns a boolean depending on if the two PhysicsObjects hits eachother, uses different methods depending on if it's rect or circle
  public boolean collisionDetection(PhysicsObject first, PhysicsObject second)
  {
    if (first instanceof Circle && second instanceof Circle)
    {
      if (circleToCircleDetection((Circle)first, (Circle)second))
      {
        return true;
      }
    }
    if (first instanceof Rect && second instanceof Rect)
    {
      if (rectToRectDetection((Rect)first, (Rect)second))
      { 
        return true;
      }
    }
    if (first instanceof Circle && second instanceof Rect || first instanceof Rect && second instanceof Circle)
    {
      if (first instanceof Circle && CircleToRectDetection((Circle)first, (Rect)second))
        return true;
      else if (first instanceof Rect && CircleToRectDetection((Circle)second, (Rect)first))
        return true;
    }
    return false;
  }

  //Start point for collision detection, calls for detection on two specifik methods and turns around  calls the appropiate method to check for collisions(boolean) and then activates the response if the value is true.
  void collisionDetection()
  {
    PhysicsObject first;
    PhysicsObject second;

    for (int i=0; i<objectArray.size(); i++)
    {
      for (int j=i+1; j<objectArray.size(); j++)
      {
        first = objectArray.get(i);
        second = objectArray.get(j);
        if (collisionDetection(first, second)) {
          if ( first instanceof Rect && second instanceof Circle)
            collisionResponse(second, first);
          else
            collisionResponse(first, second);
        }
      }
    }
  }

  //Calculates the outcome of a collision between two objects. Uses mass and velocity to calculate this. 
  void collisionResponse(PhysicsObject hitFirst, PhysicsObject hitSecond)
  {
    if (hitFirst.vanishOnImpact == true) {
      objectArray.remove(hitFirst);
      return;
    }
    if (hitSecond.vanishOnImpact == true) {
      objectArray.remove(hitSecond);
      return;
    }
    /*
    This part of our code is heavily inspired by Darran Jamiesons code example on elastic collision
     we took hes code and converted it so it would fit to our code.
     URL: https://gamedevelopment.tutsplus.com/tutorials/when-worlds-collide-simulating-circle-circle-collisions--gamedev-769
     */
    float newV1X=0, newV1Y=0;
    float newV2X=0, newV2Y=0;
    if (hitFirst.bounceOnImpact == true)
    {
      newV1X = (hitFirst.velocity.x * (hitFirst.mass - hitSecond.mass)+(2* hitSecond.mass * hitSecond.velocity.x))/(hitSecond.mass+hitFirst.mass);
      newV1Y = (hitFirst.velocity.y * (hitFirst.mass - hitSecond.mass)+(2* hitSecond.mass * hitSecond.velocity.y))/(hitSecond.mass+hitFirst.mass);
    }

    if (hitSecond.bounceOnImpact == true)
    {
      newV2X = (hitSecond.velocity.x * (hitSecond.mass - hitFirst.mass)+(2.0f* hitFirst.mass * hitFirst.velocity.x))/(hitFirst.mass+hitSecond.mass);
      newV2Y = (hitSecond.velocity.y * (hitSecond.mass - hitFirst.mass)+(2.0f* hitFirst.mass * hitFirst.velocity.y))/(hitFirst.mass+hitSecond.mass);
    }

    if (hitFirst.bounceOnImpact == true)
    {
      if (!hitSecond.keepXConstant) 
        hitFirst.velocity.x = newV1X;
      else
        hitFirst.velocity.x = - hitFirst.velocity.x;
      if (!hitSecond.keepXConstant || hitSecond.velocity.y < 0.2)
        hitFirst.velocity.y = newV1Y;

      if (!hitSecond.keepYConstant) 
        hitFirst.velocity.y = newV1Y;
      else
        hitFirst.velocity.y = - hitFirst.velocity.y;
      if (!hitSecond.keepYConstant || hitSecond.velocity.x < 0.2)
        hitFirst.velocity.x = newV1X;
    }


    if (hitSecond.bounceOnImpact == true)
    {
      if (!hitFirst.keepXConstant)
        hitSecond.velocity.y =  newV2Y;
      else
        hitSecond.velocity.y = -hitSecond.velocity.y;
      if (!hitFirst.keepYConstant || hitFirst.velocity.x < 0.2)
        hitSecond.velocity.x =  newV2X;

      if (!hitFirst.keepYConstant)
        hitSecond.velocity.x =  newV2X;
      else
        hitSecond.velocity.x = -hitSecond.velocity.x;
      if (!hitFirst.keepYConstant || hitFirst.velocity.y < 0.2)
        hitSecond.velocity.y =  newV2Y;
    }
  }


  //checks if rectangles collides
  boolean rectToRectDetection(Rect first, Rect second) {
    /*
    This part of out code is inspired by the Youtuber: Coding Math, 
     and hes video about Matematics behind Collision detection.
     URL: https://www.youtube.com/watch?v=NZHzgXFKfuY&t=672s
     */
    float maxFirstRectX = max(first.pos.x, first.pos.x+first.w);
    float minFirstRectX = min(first.pos.x, first.pos.x+first.w);
    float maxSecondRectX = max(second.pos.x, second.pos.x+second.w);
    float minSecondRectX = min(second.pos.x, second.pos.x+second.w);
    float maxFirstRectY = max(first.pos.y, first.pos.y+first.h);
    float minFirstRectY = min(first.pos.y, first.pos.y+first.h);
    float maxSecondRectY = max(second.pos.y, second.pos.y+second.h);
    float minSecondRectY = min(second.pos.y, second.pos.y+second.h);

    if (maxFirstRectX >= minSecondRectX && minFirstRectX <= maxSecondRectX && maxFirstRectY >= minSecondRectY && minFirstRectY <= maxSecondRectY) 
    {
      if (first.gotHitBy==second || second.gotHitBy == first) 
        return false;
      trueGotHit(first, second);
      return true;
    } else {
      if (first.gotHitBy==second || second.gotHitBy == first)
        falseGotHit(first, second);
    }
    return false;
  }

  //checks if circles collides
  boolean circleToCircleDetection(Circle first, Circle second)
  { 
    float distX, distY;
    distX = first.pos.x-second.pos.x;
    distY = first.pos.y-second.pos.y;
    float distance = sqrt((distX*distX) + (distY*distY));
    if (distance<(first.radius + second.radius))
    {
      if (first.gotHitBy==second || second.gotHitBy == first)  return false;

      trueGotHit(first, second);
      return true;
    } else {
      if (first.gotHitBy==second || second.gotHitBy == first)
        falseGotHit(first, second);
    }
    return false;
  }
  //checks if circles and rectangles collides
  boolean CircleToRectDetection(Circle circle, Rect rect) {

    float distX = Math.abs(circle.pos.x - rect.pos.x-rect.w/2);
    float distY = Math.abs(circle.pos.y - rect.pos.y-rect.h/2);

    /*
    This part of our code with disXx > rect.w/2 is a code made by markE on stackoverflow,
     that we use in our program, implemented with our own code.
     URL: https://stackoverflow.com/questions/21089959/detecting-collision-of-rectangle-with-circle
     */

    //first checks if the circle and rectangle are so far away that a fast return false can be made.
    if (distX > (rect.w/2 + circle.radius)) {
      if (circle.gotHitBy==rect || rect.gotHitBy == circle)
        falseGotHit(circle, rect);
      return false;
    }
    if (distY > (rect.h/2 + circle.radius)) {
      if (circle.gotHitBy==rect || rect.gotHitBy == circle)
        falseGotHit(circle, rect);
      return false;
    }
    //then checks if the circle and rectangle are so close that a fast return true can be made.
    if (distX <= (rect.w/2)) {
      if (circle.gotHitBy==rect || rect.gotHitBy == circle)  return false;
      trueGotHit(circle, rect);
      return true;
    } 
    if (distY <= (rect.h/2)) {
      if (circle.gotHitBy==rect || rect.gotHitBy == circle)  return false;
      trueGotHit(circle, rect);
      return true;
    }
    //then we check the area inbetween, this is mostly for the corners of the rectangle.
    float dx=distX-rect.w/2;
    float dy=distY-rect.h/2;
    boolean col = ((dx*dx+dy*dy)<(circle.radius*circle.radius)); 
    if (col)
    {
      if (circle.gotHitBy==rect || rect.gotHitBy == circle)  return false;
      trueGotHit(circle, rect);
      return true;
    } else
    {
      if (circle.gotHitBy==rect || rect.gotHitBy == circle)
        falseGotHit(circle, rect);
      return false;
    }
  }

  //Because this behaviour happens often, these methods were made. They are made to make the object remember who they were hit by. So that it won't collide with it again immediatly.
  void falseGotHit(PhysicsObject first, PhysicsObject second)
  {
    first.gotHitBy =null;
    second.gotHitBy = null;
  }
  void trueGotHit(PhysicsObject first, PhysicsObject second)
  {
    first.gotHitBy = second;
    second.gotHitBy = first;
  }
}

//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//  

//This class is the groundelement for every object with physics capabilities. Has the needed attributes every object needs and contains the booleans for custom behaviour
class PhysicsObject {
  public PVector pos = new PVector();
  PVector velocity = new PVector();
  boolean vanishOnImpact = false;
  boolean bounceOnImpact = true;
  boolean constrainedInFrame = true;
  float mass;
  float oldMouseX;
  float oldMouseY;
  boolean mouseUse = false;
  boolean keepXConstant = false;
  boolean keepYConstant = false;
  PhysicsObject gotHitBy;
  String type; 

  //moves the object after calculations
  void moveObject()
  {
    if (mouseUse)
      mouseUpdate();
    else
      pos = pos.add(velocity);
  }
  //makes it so that is possible to update velocity without hacking the code.
  void setVelocity(PVector velocity) {
    this.velocity = velocity;
  }
  PVector getVelocity() {
    return velocity;
  }
  void setVelocity(float velX, float velY) {
    velocity.x = velX;
    velocity.y = velY;
  }
  PVector getPos() {
    return pos;
  }
  void setPos(float posX, float posY)
  {
    pos.x = posX;
    pos.y = posY;
  }
  void setPos(PVector pos) {
    this.pos = pos;
  }


  //makes it so that is possible to add a velocity without hacking the code.
  void addVelocity(PVector velocity) {
    this.velocity = this.velocity.add(velocity);
  }
  void addVelocity(float velX, float velY) {
    velocity.x += velX;
    velocity.y += velY;
  }

  //calculates velocity by the difference betweeen the mouse pos and the mouse pos in the last frame.
  void mouseUpdate()
  {
    setVelocity(new PVector(mouseX-oldMouseX, mouseY-oldMouseY));
    oldMouseX=mouseX;
    oldMouseY=mouseY;
    if (!keepXConstant)
      pos.x = mouseX;
    pos.y = mouseY;
  }

  void draw()
  {
  }
}

//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//  

//this class represents rectangled physicsobjects, can be used on its own but also with an extension to give custom classes a rigidbody.
public class Rect extends PhysicsObject {
  float w;
  float h;
  
  public Rect() {
  }
  //needed parameters for a rectangle.
  public Rect(float posX, float posY, float w, float h, float xVelocity, float yVelocity)
  {
    pos.x = posX;
    pos.y = posY;
    this.w = w;
    this.h = h;
    velocity.x=xVelocity;
    velocity.y=yVelocity;
    calculateMass();
    type = "Rectangle";
  }
  void setWidth(float w) {
    this.w = w;
    calculateMass();
  }
  void setHeight(float h) {
    this.h = h;
    calculateMass();
  }

  void calculateMass() {
    mass=w*h;
  }
  //draws the rectangle, draws it on the mouse pos if chosen.
  void draw() {

    if (mouseUse) { 
      pos.x = mouseX; 
      pos.y = mouseY;
    }
    rect(pos.x, pos.y, w, h);
  }
}

//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//  

//this class represents circle physicsobjects, can be used on its own but also with an extension to give custom classes a rigidbody.
public class Circle extends PhysicsObject {
  float radius;

  //needed parameters for a circle velocity are here given a standard velocity of 1.
  public Circle(float posX, float posY, float diameter)
  {
    pos.x = posX;
    pos.y = posY;
    this.radius = diameter/2;
    calculateMass();
    velocity.x = 1;
    velocity.y = 1;
    type = "Circle";
  }

  //needed parameters for a circle.
  public Circle(float posX, float posY, float diameter, float xVelocity, float yVelocity)
  {
    pos.x = posX;
    pos.y= posY;
    this.radius = diameter/2;
    velocity.x = xVelocity;
    velocity.y = yVelocity;
    calculateMass();
    type = "Circle";
  }
  void setDiameter(float diameter) {
    radius = diameter/2;
  }

  void calculateMass() {
    mass=PI*(this.radius*this.radius);
  }

  //draws the circle, draws it on the mouse pos if chosen.
  public void draw()
  {
    ellipse(pos.x, pos.y, radius*2, radius*2);
  }
}