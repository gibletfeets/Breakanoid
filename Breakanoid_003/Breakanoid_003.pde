color[][] blockColors = {{#4EFFEF, #73A6AD, #9B97B2, #D8A7CA, #C7B8EA},
                         {#331832, #D81E5B, #F0544F, #C6D8D3, #FDF0D5},
                         {#5DFDCB, #90D7FF, #C9F9FF, #BFD0E0, #B8B3BE},
                         {#C9E4CA, #87BBA2, #55828B, #3B6064, #364958},
                         {#5C2751, #6457A6, #9DACFF, #76E5FC, #4BC0D9}};


final int blockWidth = 40;
final int blockHeight = 16;
final int blocksperRow = 13;
final int blocksperColumn = 5;

final int marginSize = 10;
final int gameWidth = blocksperRow*blockWidth+marginSize; //
final int screenWidth = gameWidth + 140; // 
final int screenHeight = 680;
final int paddleLine = screenHeight - 40;

int gameScore = 0;
int searchDepth = 5;
boolean debugMode = false;
int lives = 3;
int level = 0;
int blocksRemaining;


PFont gameFont;
ParticleManager ballFX = new ParticleManager();
paddleObject playerPaddle;
ballObject gameBall;
blockObject[] blockList = new blockObject[blocksperRow*blocksperColumn];
boolean blocksDropped = false;

void settings()
{
  size(screenWidth,screenHeight);
}

void setup()
{
  playerPaddle = new paddleObject(gameWidth/2,paddleLine,40,10);
  defineBlocks();
  gameFont = createFont("Lucida Console",32);
  rectMode(RADIUS);
  ellipseMode(RADIUS);
}

void draw()
{
  if (gameBall != null) fill(20,20,43,187-constrain(5*gameBall.currentCombo,0,100));
  else fill(20,20,43,187);
  rectMode(CORNER);
  rect(0,0,gameWidth,screenHeight);
  fill(60,60,86);
  rect(gameWidth,0,screenWidth,screenHeight);
  rectMode(RADIUS);
  noStroke();
  stroke(0,53,243);
  fill(0,243,53);
  textFont(gameFont,16);
  textAlign(LEFT);
  text("Level: " + str(level+1),gameWidth+marginSize,20);
  if (blocksDropped) // check if cool animation is completed before doing main game loop
  {
    if (lives > -1)
    {
      text("Score: " + str(gameScore),gameWidth+marginSize,40);
      text("Lives: " + str(lives),gameWidth+marginSize,60);
      if (gameBall != null && gameBall.currentCombo > 1)
      text("Combo: " + str(gameBall.currentCombo),gameWidth+marginSize,80);
    }
    //wow this really needs to be made into a switch statement
    if (keyPressed)
    {

      if (key == ' ' && lives == -1)
      {
        lives = 3;
        gameScore = 0;
        gameBall = null;
        defineBlocks();
        return;
      } 
      if      (keyCode == RIGHT || key == 'd' || key == 'D') playerPaddle.xTarget += 5;
      else if (keyCode == LEFT  || key == 'a' || key == 'A')  playerPaddle.xTarget -= 5;
    }
    if (gameBall == null || !gameBall.isAlive) 
    {
      if (gameBall != null)
      {
        if (lives > 0) 
        {
          lives--;
          gameBall = new ballObject(new vec2(gameWidth/2,screenHeight/2),new vec2(random(-TAU/8,TAU/8)));
        }
        else 
        {
          lives = -1;
          textAlign(CENTER);
          textFont(gameFont,40);
          text("GAME OVER!",gameWidth/2,screenHeight/2);
          textFont(gameFont,20);
          text("Press Space to restart",gameWidth/2,screenHeight/2 + 60);
          text("the fight against the blocks",gameWidth/2,screenHeight/2 + 80);
        }
      }
      else gameBall = new ballObject(new vec2(gameWidth/2,screenHeight/2),new vec2(random(-TAU/8,TAU/8)));
    }
    else 
    {
      gameBall.move();
      if (blocksRemaining == 0)
      {
        level++;
        lives++;
        defineBlocks();
        gameBall = null;
        return;
      }
    }
  } else
  {
    dropBlocks();
  }
  displayBlocks();
  playerPaddle.move();
  ballFX.updateParticles();
  playerPaddle.display();
}
