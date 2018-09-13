int ballWidth = 7;

class ballObject
{
  vec2 pos, vel;
  bounceEvent nextBounce;
  color ballColor = color(255,0,0);
  int currentCombo = 0;
  boolean isAlive;
  float colorMap = 0;
  
  ballObject(vec2 a, vec2 b)
  {
    pos = a.copy();
    vel = b.copy();
    vel.setMag(7);
    isAlive = true;
  }
  
  void move()
  {
    refreshBlocks();
    this.nextBounce = plotTrajectory(pos,vel,searchDepth);
    {
      if (nextBounce.pos.distance(pos) > vel.mag())
      {
        pos.add(vel);
      }
      else
      {
        if (nextBounce.vel.mag() > 0)
        {
          colorMap = 1;
          float remainingDistance = vel.mag();
          while (remainingDistance > 0)
          {
            remainingDistance -= nextBounce.pos.distance(pos);
            pos = nextBounce.pos.copy();
            vel = nextBounce.vel;
            if (nextBounce.assignedBlock >= 0) 
            {
              ballFX.generateParticles(blockList[nextBounce.assignedBlock].pos,blockList[nextBounce.assignedBlock].blockColor);
              blockList[nextBounce.assignedBlock].pos.y = -20;
              jitterBlocks(pos);
              blocksRemaining--;
              currentCombo++;
              gameScore += currentCombo*5*(level+1);
            }
            else if (nextBounce.assignedBlock == -2)
            {
              currentCombo = 0;
            }
            this.nextBounce = plotTrajectory(pos,vel,2);
            if (nextBounce.pos.distance(pos) > remainingDistance)
            {
              vec2 remainder = vel.copy();
              remainder.setMag(remainingDistance);
              pos.add(remainder);
              remainingDistance = 0;
            }
          }
        }
        else 
        {
          isAlive = false;
          return;
        }
      }
      float dc = 0 - colorMap;
      colorMap += 0.01 * dc;
      noStroke();
      fill(lerpColor(color(255,0,0),color(255,255,255),colorMap));
      ellipse (pos.x,pos.y,ballWidth,ballWidth);
    }
  }
  
}

class bounceEvent
{
  vec2 pos, vel;
  bounceEvent nextBounce;
  int assignedBlock = -1;
  
  bounceEvent(vec2 a, vec2 b, int c)
  {
    pos = a.copy();
    vel = b.copy();
    if (c > 0) nextBounce = plotTrajectory(pos, vel, c);
  }
}

bounceEvent plotTrajectory(vec2 a,vec2 b, int depth)
{
  stroke(lerpColor(color(0,255,0,200),color(255,0,0,40),map(depth,0,searchDepth,1,0)));
  noFill();
  if (debugMode) ellipse(a.x,a.y,ballWidth,ballWidth);
  
  vec2 cursor = a.copy();
  vec2 norm = b.copy();
  norm.normalize();
  boolean moving = true;
  int blockID = -1;
  
  while (moving)
  {
    if(cursor.y < 7*marginSize+blocksperColumn*blockHeight)
    {
        for(int i = 0; i < blockList.length; i++)
        {
          if (blockList[i].getDistance(new vec2(cursor.x+norm.x,cursor.y+norm.y)) < ballWidth && blockList[i].collisionID == -1)
          {
            norm = blockList[i].getNormal(cursor);
            blockList[i].collisionID = depth;
            blockID = i;
            moving = false;
            break;
          }
        }
    }
    //make sure cursor is in relevant area before doing complex ellipse math
    if(cursor.y < playerPaddle.pos.y + 20 && cursor.y > playerPaddle.pos.y - 20)
    {
      if (playerPaddle.getDistance(new vec2(cursor.x+norm.x,cursor.y+norm.y)) < ballWidth)
      {
        //touch paddle
        moving = false;
        blockID = -2;
        norm = playerPaddle.getNormal(cursor);
      }
    }
    if (cursor.x + norm.x - ballWidth < 0 || cursor.x + norm.x + ballWidth > gameWidth)
    {
      //side reflect
      moving = false;
      norm = new vec2(setSign(-1,cursor.x - gameWidth/2),0);
    }else if (cursor.y + norm.y - ballWidth < 0)
    {
      //top reflect
      moving = false;
      norm = new vec2(0,-1);
    }else if (cursor.y + norm.y - ballWidth > screenHeight)
    {
      //die
      moving = false;
      norm = new vec2(0,0);
    }
    else
    {
      cursor.add(norm);
    }
  }
  
  line(a.x,a.y,cursor.x,cursor.y);
  depth--;
  vec2 newVelocity = reflectVector(b,norm);
  bounceEvent result = new bounceEvent(cursor,newVelocity,depth);
  if (blockID != -1) result.assignedBlock = blockID;
  if (norm.mag() > 0) return result;
  else                return new bounceEvent(cursor,new vec2(0,0),0);
}
