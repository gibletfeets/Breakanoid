class blockObject
{
  vec2 pos, size = new vec2(blockWidth/2,blockHeight/2);
  vec2 jitterVec = new vec2(random(0,TAU));
  int specialOffset = int(random(0,100));
  color blockColor;
  int collisionID = -1;
  int jitter = 0;
  
  blockObject(vec2 a, color b)
  {
    specialOffset = int(random(0,100));
    blockColor = b;
    pos = a.copy();
  }
  
  void display()
  {
    strokeWeight(4);
    strokeJoin(BEVEL);
    stroke(color(red(blockColor)/2,
                 green(blockColor)/2,
                 blue(blockColor)/2));
    fill(blockColor);
    if ((frameCount+specialOffset)%2 == 0) jitterVec = new vec2(random(0,TAU));
    if (jitter > 20) 
    {
      jitterVec.setMag(jitter/20);
      jitter --;
      rect(pos.x+jitterVec.x,pos.y+jitterVec.y,size.x-2,size.y-2);
    }
    else
    {
      rect(pos.x,pos.y,size.x-2,size.y-2);
      jitter = 0;
    }
    strokeWeight(1);
    noStroke();
  }
  
  float getDistance(vec2 query)
  {
    vec2 position = query.copy();
    vec2 closestPoint = closestPointRectangle(pos,size,position);
    position.sub(closestPoint);
    return position.mag();
  }
  
  vec2 getNormal(vec2 query)
  {
    float dx = abs(query.x - pos.x) - size.x, dy = abs(query.y - pos.y) - size.y;
    if (dx < 0)      // top/bottom
    {
      if (query.y < pos.y) return new vec2(0,-1);
      else                 return new vec2(0,1);
    }
    else if (dy < 0) // left/right
    {
      if (query.x < pos.x) return new vec2(-1,0);
      else                 return new vec2(1,0);
    }
    else             // corner
    {
      float cx = pos.x, cy = pos.y;
      if (query.y < pos.y) cy += -size.y;
      else                 cy += size.y;
      if (query.x < pos.x) cx += -size.x;
      else                 cx += size.x;
      vec2 norm = new vec2(query.x - cx, query.y - cy);
      norm.normalize();
      return norm;
    }
  }
}

void defineBlocks()
{
  for(int i = 0; i < blocksperColumn; i++)
  {
    for (int k = 0; k < blocksperRow; k++)
    {
      blockList[i*blocksperRow + k] = new blockObject(new vec2(marginSize/2+blockWidth/2+blockWidth*k,
                                                             6*marginSize+blockHeight*i),
                                          blockColors[(i*blocksperRow+k)%blockColors.length]);
    }
  }
}
void displayBlocks()
{
  for(int i = 0; i < blockList.length; i++)
  {
    blockList[i].display();
  }
}
void refreshBlocks()
{
  for(int i = 0; i < blockList.length; i++)
  {
    blockList[i].collisionID = -1;
  }
}
void jitterBlocks(vec2 query)
{
  for(int i = 0; i < blockList.length; i++)
  {
    float distance = map(blockList[i].getDistance(query),10,500,5,1);
    blockList[i].jitter = constrain(blockList[i].jitter + int(sq(distance)* (gameBall.currentCombo)),0,80);
  }
}

class paddleObject
{
  vec2 pos = new vec2(0,0);
  vec2 size = new vec2(0,0);
  float xTarget;
  float easing = 0.2;
  rectObject paddleBox;
  
  paddleObject(float e0, float e1, float a, float b)
  {
    pos.x = e0;
    pos.y = e1; 
    size.x = a;
    size.y = b;
    paddleBox = new rectObject(e0, e1 + b/2, a, b/2);
  }
  
  void move()
  {
    xTarget = constrain (xTarget, size.x, gameWidth-size.x);
    float dx = xTarget - pos.x;
    if (abs(dx) > 1) // snap to pixel noice
    {
      pos.x += easing * dx;
    }
    else
    {
      pos.x = xTarget;
    }
    paddleBox.pos.x = pos.x;
  }
  
  void display()
  {
    fill(255);
    noStroke();
    ellipse(pos.x,pos.y,size.x,size.y); 
    rect(paddleBox.pos.x, paddleBox.pos.y,
         paddleBox.size.x,paddleBox.size.y);
    fill(255,0,0);
    if (debugMode) ellipse(xTarget,pos.y,5,5);
  }
  
  vec2 closestPoint(vec2 query)
  {
    if (query.y <= pos.y) return closestPointEllipse(pos,size,query);
    else                 return closestPointRectangle(pos,size,query);
  }
  
  float getDistance(vec2 query)
  {
    if (query.y <= pos.y)
    {
      vec2 position = query.copy();
      vec2 closestPoint = closestPointEllipse(pos,size,position);
      position.sub(closestPoint);
      return (position.mag());
    }
    else
    {
      return (paddleBox.getDistance(query));
    }
  }
  
  vec2 getNormal(vec2 q)
  {
    if (q.y <= pos.y)
    {
      vec2 query = closestPoint(q);
      query.sub(pos);
      vec2 Normal = new vec2(query.y + query.x * sq(size.y),
                           -(query.x - query.y * sq(size.x)));
      Normal.normalize();
      return Normal;
    }
    else
    {
      return (paddleBox.getNormal(q));
    }
  }
}

class rectObject
{
  vec2 pos = new vec2(0,0);
  vec2 size = new vec2(0,0);
  
  rectObject(float r0, float r1, float a, float b)
  {
    pos.x = r0;
    pos.y = r1;
    size.x = a;
    size.y = b;
  }
  
  void display()
  {
    noFill();
    stroke(255);
    rect(pos.x,pos.y,size.x,size.y);

  }
  
  float getDistance(vec2 query)
  {
    vec2 position = query.copy();
    vec2 closestPoint = closestPointRectangle(pos,size,position);
    position.sub(closestPoint);
    return position.mag();
  }
  
  vec2 getNormal(vec2 query)
  {
    float dx = abs(query.x - pos.x) - size.x, dy = abs(query.y - pos.y) - size.y;
    if (dx < 0)      // top/bottom
    {
      if (query.y < pos.y) return new vec2(0,-1);
      else                 return new vec2(0,1);
    }
    else if (dy < 0) // left/right
    {
      if (query.x < pos.x) return new vec2(-1,0);
      else                 return new vec2(1,0);
    }
    else             // corner
    {
      float cx = pos.x, cy = pos.y;
      if (query.y < pos.y) cy += -size.y;
      else                 cy += size.y;
      if (query.x < pos.x) cx += -size.x;
      else                 cx += size.x;
      vec2 norm = new vec2(query.x - cx, query.y - cy);
      norm.normalize();
      return norm;
    }
  }
}
