int ballWidth = 5;
class Ball
{
  PVector pos;
  PVector vel;
  ballBounce nextBounce;

  Ball(PVector tempPos,PVector tempVel)
  {
    for (int i = 0; i < blockList.length; i++)
    {
      blockList[i].collisionID = -1;
    }
    pos = tempPos.copy();
    vel = tempVel;
    vel.setMag(5);
    ballBounce initBounce = new ballBounce(pos, vel);
    initBounce.findCollision(bounceDepth+1);
    nextBounce = initBounce.childBounce;
  }

  void move()
  {
    for (int i = 0; i < blockList.length; i++)
    {
      blockList[i].collisionID = -1;
    }
    //println("Repopulating list.");
    nextBounce = new ballBounce(pos, vel);
    nextBounce.findCollision(bounceDepth+1);
    this.nextBounce = nextBounce.childBounce;
    
    if (PVector.dist(pos, nextBounce.pos) > vel.mag()) 
    {
      pos.add(vel);
      //println("Healthy movement");
    }
    else
    {
      if (nextBounce.assignedBlock == -9998) return; //<>//
      print(frameCount);
      print(": Performing bounce, type: ");
      switch (nextBounce.assignedBlock)
      {
        case    -1: println("wall.");   break;
        case -9999: println("paddle."); break;
        default   : println("block.");  break;
      }
      
      // attempting to adjust for remaining velocity after a bounce, for cases where multiple bounces are occuring over a cumulative distance
      // less than the velocity of the ball - or in other words the amount of velocity traveled in a frame. needs to be made
      // such that it accounts for n number of bounces, instead of just 2. right now it outputs when there is a speed desync
      // caused by this behavior, for purposes related to sorting out what is causing abberations in the predicted pathway
      
      PVector remainder = nextBounce.vel.copy().setMag(vel.mag()-PVector.dist(pos, nextBounce.pos));
      if (nextBounce.childBounce != null && remainder.mag() > PVector.dist(nextBounce.childBounce.pos,nextBounce.pos)) 
      {
        print(frameCount);
        print(": Speed desync. distance: ");
        println(remainder.mag() - PVector.dist(nextBounce.childBounce.pos,nextBounce.pos));
      }
      pos.set(nextBounce.pos.copy().add(remainder));
      vel.set(nextBounce.vel);
      if (nextBounce.assignedBlock > -1) 
      {
        blockList[nextBounce.assignedBlock].pos.y = -20;
        //print("Block collision, Index No.");
        //println(nextBounce.assignedBlock);
      } 
    }
  }

  void drawBall()
  {
    if (nextBounce != null && debugMode && debugPaths) 
    {
      stroke(255,0,0,127);
      line (pos.x,pos.y,nextBounce.pos.x,nextBounce.pos.y);
      nextBounce.drawBounce();
    }
    fill(255);
    noStroke();
    ellipse (pos.x, pos.y, ballWidth, ballWidth);
  }

  class ballBounce
  {
    boolean isDeath = false;
    PVector pos;
    PVector vel;
    color bounceColor;
    int assignedBlock = -1;
    ballBounce childBounce;

    ballBounce(PVector tempPos, PVector tempVel)
    {
      this.pos = tempPos.copy();
      this.vel = tempVel.copy();
    }

    void findCollision(int counter)
    {
      //print("Seeking collisions, depth: "); println(counter);     
      bounceColor = lerpColor(#55FF55,#FF5555,map (counter,1,bounceDepth+1,0,1));
      PVector cursor = pos.copy();
      PVector norm = vel.copy();
      norm.setMag(0.25);
      
      while (this.childBounce == null)
      {
        cursor.add(norm);
        
        // these collision checks are honestly very suboptimal in my eyes, and are pending some overall rewriting to define
        // their boundaries. the ellipse top section for the paddle needs to be rewritten because i'm well aware of the fact
        // that the closest point to an arbitrary point outside of an ellipse, does not necessary share the same x coordinates
        // with that point.
        
        // furthermore, the check logic in general should be altered, as it's performing a rectangle/rectangle collision check
        // instead of a circle/rectangle collision check, which would make matters more accurate.
        // with that in mind, there's some rather fucky logic going on for handling cases where the ball hits a corner, and some hacky
        // solution for a weird trajectory issue that would happen when the ball is near-orthogonal to the surface normal it was getting
        // upon collision.
        
        if (cursor.x +ballWidth > player.pos.x - player.size.x //left edge
          &&cursor.x -ballWidth < player.pos.x + player.size.x //right edge
          &&cursor.y +ballWidth > player.pos.y - (player.size.y/player.size.x)*sqrt(player.size.x*player.size.x - ((cursor.x + norm.x - player.pos.x)*(cursor.x + norm.x - player.pos.x)))
          &&cursor.y -ballWidth < player.pos.y + player.size.y 
          &&assignedBlock != -9999)
        {
          PVector delta = new PVector(abs(cursor.x-player.pos.x)-player.size.x, abs(cursor.y-player.pos.y)-player.size.y);
          if (delta.y > 0 && delta.x > 0)
          {
            this.childBounce = new ballBounce(cursor, new PVector (vel.x*-1, vel.y*-1));
          } else if (delta.y > delta.x && cursor.y < player.pos.y)
          {
            float adjustedx = cursor.x + norm.x - player.pos.x;
            PVector surfaceNorm = new PVector(adjustedx/(10*sqrt(player.size.x*player.size.x-adjustedx*adjustedx)), -1);
            surfaceNorm.normalize();
            if (Float.isNaN(surfaceNorm.y))
            {
              surfaceNorm.y = abs(surfaceNorm.x)/surfaceNorm.x * 1;
            }
            stroke(255, 0, 0);
            line(cursor.x, cursor.y, cursor.x+20*surfaceNorm.x, cursor.y+20*surfaceNorm.y);
            this.childBounce  = new ballBounce(cursor, reflectVector(vel, surfaceNorm));
            if (abs(PVector.dot(surfaceNorm, childBounce.vel)) < 0.2 || PVector.dist(pos, childBounce.pos) < 10)
            {
              //println("Shifting");
              childBounce.vel.set(vel);
              childBounce.pos.add(PVector.mult(vel, 5));
            }
          } else
          {
            this.childBounce = new ballBounce(cursor, new PVector(vel.x*-1, vel.y));
          }
          this.childBounce.assignedBlock = -9999;
        }


        for (int i = 0; i < blockList.length; i++)
        {
          //search one step ahead for intersect
          if (cursor.x + ballWidth > blockList[i].pos.x - blockList[i].size.x //left edge
           && cursor.x - ballWidth < blockList[i].pos.x + blockList[i].size.x //right edge
           && cursor.y + ballWidth > blockList[i].pos.y - blockList[i].size.y //top edge
           && cursor.y - ballWidth < blockList[i].pos.y + blockList[i].size.y //bottom edge
           && (blockList[i].collisionID == counter || blockList[i].collisionID == -1))
          {
            blockList[i].collisionID = counter;
            PVector delta = new PVector(abs(cursor.x-blockList[i].pos.x)-blockList[i].size.x, abs(cursor.y-blockList[i].pos.y)-blockList[i].size.y);
            if (delta.y > delta.x)
            {
              this.childBounce = new ballBounce(cursor, new PVector(vel.x, vel.y*-1));
            } else
            {
              this.childBounce = new ballBounce(cursor, new PVector(vel.x*-1, vel.y));
            }
            this.childBounce.assignedBlock = i;
            break;
          }
        }
        if (       cursor.x >gameWidth - ballWidth)
        {
          this.childBounce = new ballBounce(cursor, reflectVector(vel, new PVector(-1, 0)));
        } else if (cursor.x < ballWidth)
        {
          this.childBounce = new ballBounce(cursor, reflectVector(vel, new PVector(1, 0)));
        } else if (cursor.y < ballWidth)
        {
          this.childBounce = new ballBounce(cursor, reflectVector(vel, new PVector(0, 1)));
        } else if (cursor.y > screenHeight+2*ballWidth)
        {
          this.childBounce = new ballBounce(cursor,vel);
          this.childBounce.assignedBlock = -9998;
          this.childBounce.bounceColor = #000000;
          counter = 0;
        }
      }
      counter--;
      if (counter > 0 && this.childBounce != null) this.childBounce.findCollision(counter);
      //else println("Collision seek complete.");
    }

    PVector reflectVector(PVector temp, PVector surfaceNormal)
    {
      PVector tobeReflected = temp.copy();
      return tobeReflected.sub(PVector.mult(PVector.mult(surfaceNormal, PVector.dot(tobeReflected, surfaceNormal)), 2));
    }

    void drawBounce()
    {
      if (this.childBounce != null)
      {
        stroke(255, 40);
        strokeWeight(1);
        line(this.pos.x, this.pos.y, childBounce.pos.x, childBounce.pos.y);
        childBounce.drawBounce();
      }
      stroke (bounceColor, 40);
      strokeWeight(2);
      line(pos.x, pos.y, pos.x+this.vel.x, pos.y+this.vel.y);
      if (assignedBlock == -9998) fill(255);
      else noFill();
      ellipse(pos.x, pos.y, ballWidth, ballWidth);
    }
  }
}
