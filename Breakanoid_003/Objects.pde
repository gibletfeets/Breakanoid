class blockObject
{
  vec2 pos, size = new vec2(blockWidth/2,blockHeight/2);
  vec2 jitterVec = new vec2(random(0,TAU));
  int specialOffset = int(random(0,100));
  color blockColor;
  int collisionID = -1;
  int jitter = 0;
  int timer;
  float yTarget;
  boolean inPosition = false;
  
  blockObject(vec2 a, color b)
  {
    pos =  new vec2(a.x,-20);
    yTarget = a.y;
    specialOffset = int(random(0,100));
    blockColor = b;
    timer = int(random(0, 90));
  }
  
  void display()
  {
    strokeWeight(3);
    strokeJoin(BEVEL);
    stroke(color(red(blockColor)/2,
                 green(blockColor)/2,
                 blue(blockColor)/2));
    fill(blockColor);
    if ((frameCount+specialOffset)%2 == 0) jitterVec = new vec2(random(0,TAU));
    if (jitter > 0) 
    {
      jitterVec.setMag(float(jitter)/20);
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
  
  void dropIn() 
  {
    if (timer != 0) 
    {
      timer--;
      return;
    } else 
    {
      float dy = yTarget - pos.y;
      pos.y += dy*0.3;
      if (dy < 1) 
      {
        pos.y = yTarget;
        inPosition = true;
      }
    }
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
  blocksDropped = false;
  blocksRemaining = blocksperColumn*blocksperRow;
  for(int i = 0; i < blocksperColumn; i++)
  {
    for (int k = 0; k < blocksperRow; k++)
    {
      blockList[i*blocksperRow + k] = new blockObject(new vec2(marginSize/2+blockWidth/2+blockWidth*k,
                                                             6*marginSize+blockHeight*i),
                                          blockColors[level%blockColors.length][(i*blocksperRow+k)%5]);
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

void dropBlocks()
{
  int numberComplete = 0;
  for (int i = 0; i < blocksperColumn; i++)
  {
    for (int k = 0; k < blocksperRow; k++)
    {
      blockList[k+i*blocksperRow].dropIn();
      blockList[k+i*blocksperRow].display();
      if (blockList[k+i*blocksperRow].inPosition) numberComplete++;
    }
  }
  blocksDropped = (numberComplete == blocksperColumn * blocksperRow);
}

class paddleObject
{
  vec2 pos = new vec2(0,0);
  vec2 size = new vec2(0,0);
  float xTarget = gameWidth/2;
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
    fill(#A9B2AB);
    noStroke();
    ellipse(pos.x,pos.y,size.x,size.y); 
    rect(paddleBox.pos.x, paddleBox.pos.y,
         paddleBox.size.x,paddleBox.size.y);
    fill(40);
    rect(pos.x,pos.y,size.x/2,4);
    ellipse(pos.x,pos.y-4,size.x/2,4);
    ellipse(pos.x,pos.y+4,size.x/2,2);
    fill(255,0,0);
    if (gameBall != null)  
    {
      vec2 relative = new vec2(gameBall.pos.x-pos.x,gameBall.pos.y-pos.y);
      relative.x = map(relative.x,-pos.x,pos.x,-size.x/2,size.x/2);
      println(relative.x);
      ellipse(constrain(xTarget+((pos.x+size.x/2 - 6)*(relative.x)/gameWidth),
                                             pos.x-(size.x/2 - 6),
                                             pos.x+(size.x/2 - 6)),
                                             map(gameBall.pos.y, 0, 800, 
                                             pos.y-4 - (4/(size.x/2) * sqrt(abs(sq(size.x/2)-sq(relative.x)))),
                                             pos.y-4 + (2/(size.x/2) * sqrt(abs(sq(size.x/2)-sq(relative.x)))))+3, 
                                             3,3);

    }else                   ellipse(constrain(xTarget,pos.x-(size.x/2 - 6),pos.x+(size.x/2 - 6)),pos.y,3,3);
   
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
