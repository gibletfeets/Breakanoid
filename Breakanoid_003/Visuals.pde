void drawArrow(vec2 start, vec2 end)
{
  vec2 arrow = end.copy();
  arrow.sub(start);
  arrow.setMag(15);
  arrow.rotate(-TAU/16);
  line (start.x,start.y,end.x,end.y);
  line (end.x,end.y,end.x-arrow.x,end.y-arrow.y);
  arrow.rotate(TAU/8);
  line (end.x,end.y,end.x-arrow.x,end.y-arrow.y);
}
class ParticleManager 
{
    ArrayList<Particle> particles = new ArrayList<Particle>();

    color rgbTarget = color(20, 20, 43);
    void updateParticles() 
    {
      for (int i = particles.size() - 1; i >= 0; i--) 
      {
        particles.get((particles.size() - (i+1))).animate();
        if (particles.get(i).size <= 0.05||particles.get(i).pos.y > screenHeight) 
        {
          particles.remove(i);
        }
      }
    }

    void generateParticles(vec2 tempVector, color tempColor) 
    {
      for (int i = int(random(6, 12)); i > 0; i--) 
      {
        particles.add(new Particle(new vec2(tempVector.x+random(-blockWidth/2,blockWidth/2),tempVector.y), tempColor));
      }
    }

    class Particle 
    {
      float size = random(10, 15);
      float timer = random(0, TAU);
      float spinRate = random(0.2,0.7);
      vec2 pos = new vec2(0, 0);
      vec2 vel = new vec2(0, 0);
      color rgb;

      Particle(vec2 tempPos, color tempColor) 
      {
        pos = tempPos.copy();
        rgb = lerpColor(tempColor,
                        color(red(tempColor)-50,
                            green(tempColor)-50,
                             blue(tempColor)-20),random(0.5,1));
      }


      void animate() 
      {
        timer++;
        if (random(0,100) > 95) 
        {
          vec2 push = new vec2(random(0,TAU));
          vel.y += push.y/2;
          vel.x += push.x/2;
        }
        vel.y += 0.1;
        pos.add(vel);
        float dSize = 0 - size;
        size += dSize * 0.02;
        fill(rgb);
        rgb = lerpColor(rgb,color(20,20,43),0.01);
        triangle(pos.x+size*2*cos((timer/TAU)*spinRate),           pos.y+size*sin((timer/TAU)*spinRate), 
                 pos.x+size * cos((timer/TAU)*spinRate+TAU/3),     pos.y+size*sin((timer/TAU)*spinRate+TAU/3), 
                 pos.x+size * cos((timer/TAU)*spinRate+2*(TAU/3)), pos.y+size*sin((timer/TAU)*spinRate+2*(TAU/3)));
      }
    }
  }
