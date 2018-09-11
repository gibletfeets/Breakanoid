class Paddle
{
  PVector pos;
  PVector size;
  float xTarget = gameWidth/2;
  float easing = 0.1;
  

  Paddle()
  {
    pos = new PVector(gameWidth/2, paddleLine);
    size = new PVector(30, 3);
  }

  void updatePaddle()
  {
    
    //xTarget = mouseX;
    if (xTarget > gameWidth - size.x) xTarget = gameWidth - size.x;
    else if(xTarget < size.x)         xTarget = size.x;
    float dx = xTarget - pos.x;
    pos.x += dx * easing;
    noStroke();
    fill(255,0,0);
    ellipse(xTarget,pos.y,5,5);
    fill(255);
    ellipse(pos.x, pos.y, size.x, size.y);
    rect(pos.x, pos.y+size.y, size.x, size.y);
  }
}
