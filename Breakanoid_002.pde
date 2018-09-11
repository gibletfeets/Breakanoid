color[] blockColors = {#4EFFEF, #73A6AD, #9B97B2, #D8A7CA, #C7B8EA};
final int blockWidth = 30;
final int blockHeight = 12;
final int blocksperRow = 13;
final int blocksperColumn = 5;

final int marginSize = 10;
final int gameWidth = blocksperRow*blockWidth+marginSize;
final int screenWidth = gameWidth + 140;
final int screenHeight = 620;
final int paddleLine = screenHeight - 40;

//probably should be set somewhat low, just set really high for the sake of interesting visualization and overall debugging
//but has very little positive effect if any by being set arbitrarily high, and increases resource consumption

final int bounceDepth = 100;

boolean debugMode, debugPaths;
PFont gameFont;

Block[] blockList = new Block[blocksperColumn*blocksperRow];
Paddle player = new Paddle();
Ball gameBall;
PVector startPoint;
IntList fpsData = new IntList();

void settings()
{
  size(screenWidth, screenHeight);
}

void setup()
{
  resetBlocks();
  rectMode(RADIUS);
  ellipseMode(RADIUS);
  background(30, 30, 60);
  frameRate(60);
  gameFont = createFont("Lucida Console",11,true);
}

void keyPressed()
{
  switch(key) 
  {
    // press key 'r' to start recording 
    // after the recording has finished, the gif
    // will be saved to disc automatically
    case('r'): resetBlocks(); break;
    case('f'): 
    {
      if (debugMode) debugMode = false;
      else           debugMode = true;
      break;
    }
    case('p'):
    {
      if (debugPaths) debugPaths = false;
      else            debugPaths = true;
    }
  }
}

void mousePressed()
{
  if (startPoint == null)
  {
    startPoint = new PVector(mouseX,mouseY);
  }
}
void mouseReleased()
{
  PVector endPoint = new PVector(mouseX,mouseY);
  if (PVector.dist(startPoint,endPoint) > 1) gameBall = new Ball(startPoint,endPoint.sub(startPoint));
  startPoint = null;
}

void displayFPSHistogram()
{
  stroke(0,255,0);
  fpsData.append(int(map(frameRate,0,60,0,200)));
  if (fpsData.size() > 25) fpsData.remove(0);
  text("0",gameWidth+marginSize,600);
  text("60",gameWidth+marginSize,400);
  for (int i = fpsData.size()-1; i >= 0; i--)
  {
    line(gameWidth+marginSize+4*(fpsData.size()-i),600,gameWidth+marginSize+4*(fpsData.size()-i),600-fpsData.get(i));
  }
}

void draw()
{
  clear();
  background(30, 30, 60);
  stroke(0, 255, 63);
  strokeWeight(1);
  noFill();
  rect(0, 0, gameWidth, screenHeight);
  if (startPoint != null) drawArrow(startPoint, new PVector (mouseX,mouseY));
  for (int i = 0; i < blockList.length; i++)
  {
    blockList[i].drawBlock();
  }
  if (gameBall != null)
  {
    gameBall.move();
    gameBall.drawBall();
  }
    player.updatePaddle();
    if (debugMode) {displayFPSHistogram(); text(frameRate,screenWidth-4*marginSize,marginSize);}
}
