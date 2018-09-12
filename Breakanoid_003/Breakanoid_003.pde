color[] blockColors = {#4EFFEF, #73A6AD, #9B97B2, #D8A7CA, #C7B8EA};
final int blockWidth = 40;
final int blockHeight = 16;
final int blocksperRow = 13;
final int blocksperColumn = 5;

final int marginSize = 10;
final int gameWidth = blocksperRow*blockWidth+marginSize; //
final int screenWidth = gameWidth + 140; // 
final int screenHeight = 620;
final int paddleLine = screenHeight - 40;

int gameScore = 0;
int searchDepth = 10;
boolean debugMode = false;
int lives = 3;

PFont gameFont;
ParticleManager ballFX = new ParticleManager();
paddleObject testBedPaddle;
ballObject gameBall;
blockObject[] blockList = new blockObject[blocksperRow*blocksperColumn];

void settings()
{
  size(screenWidth,screenHeight);
}

void setup()
{
  testBedPaddle = new paddleObject(200,paddleLine,40,6);
  defineBlocks();
  gameFont = createFont("Lucida Console",32);
  rectMode(RADIUS);
  ellipseMode(RADIUS);
}

void draw()
{
  noStroke();
  if (gameBall != null) fill(20,20,43,187-constrain(5*gameBall.currentCombo,0,100));
  else fill(20,20,43,187);
  rectMode(CORNER);
  rect(0,0,gameWidth,screenHeight);
  fill(60,60,86);
  rect(gameWidth,0,screenWidth,screenHeight);
  rectMode(RADIUS);
  stroke(0,53,243);
  fill(0,243,53);
  textFont(gameFont,16);
  text("Score: " + str(gameScore),gameWidth+marginSize,20);
  if (gameBall != null && gameBall.currentCombo > 1)
  text("Combo: " + str(gameBall.currentCombo),gameWidth+marginSize,40);
  if (mousePressed)
  {
    gameBall = new ballObject(new vec2(mouseX,mouseY),new vec2(random(-TAU/8,TAU/8)));
  }
  if (keyPressed)
  {
    if (key == 'f')
    {
      if (debugMode) debugMode = false;
      else           debugMode = true;
    } else if (key == 'r')
    {
      defineBlocks();
    }
    if      (keyCode == RIGHT || key == 'd' || key == 'D') testBedPaddle.xTarget += 7;
    else if (keyCode == LEFT  || key == 'a' || key == 'A')  testBedPaddle.xTarget -= 7;
  }
  if (gameBall == null || !gameBall.isAlive) 
  {
    if (gameBall != null)
    {
      gameScore -= 200;
    }
    gameBall = new ballObject(new vec2(200,200),new vec2(random(-TAU/8,TAU/8)));
  }
  if (gameBall != null && gameBall.isAlive) gameBall.move();
  displayBlocks();
  testBedPaddle.move();
  ballFX.updateParticles();
  testBedPaddle.display();
}
