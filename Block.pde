class Block
{
  PVector pos;
  PVector size;
  color blockColor;
  int collisionID = -1;
  Block(PVector tempPos, color tempColor)
  {
    blockColor = tempColor;
    pos = tempPos.copy();
    size = new PVector(blockWidth/2, blockHeight/2);
  }

  void drawBlock()
  {
    if (debugMode&&collisionID != -1) 
    {
      textFont(gameFont,12);
      textAlign(CENTER);
      fill(blockColor);
      stroke(lerpColor(#00FF00,#FF0000,map (collisionID,1,bounceDepth+1,0,1)));
      rect(pos.x, pos.y, size.x, size.y);
      fill(lerpColor(#00FF00,#FF0000,map (collisionID,1,bounceDepth+1,0,1)));
      text(bounceDepth+2-collisionID,pos.x,pos.y+5);
      text(bounceDepth+2-collisionID,pos.x+1,pos.y+5);
    } else
    {
      noStroke();
      fill(blockColor);
      rect(pos.x, pos.y, size.x, size.y);
    }
  }
  
  PVector testCollision(PVector query)
  {
    float testX,testY;
    if (query.x < pos.x-size.x) testX = pos.x-size.x;
    else                        testX = pos.x+size.x;
    if (query.y < pos.y-size.y) testY = pos.y-size.y;
    else                        testY = pos.y+size.y;
    float distX = pos.x-testX, distY = pos.y-testY;
    float distance = sqrt(sq(distX)+sq(distY));
    if (distance <= ballWidth)
    {
      //return new PVector(xNorm,yNorm);
    }
    return new PVector(0,0);
  }
}

void resetBlocks()
{
  for (int i = 0; i < blocksperColumn; i++)
  {
    for (int k = 0; k < blocksperRow; k++)
    {
      blockList[i+k*blocksperColumn] = new Block(new PVector(marginSize/2 + blockWidth/2 + k*blockWidth, marginSize*4+i*blockHeight), blockColors[(i*blocksperRow + k)%blockColors.length]);
    }
  }
}
