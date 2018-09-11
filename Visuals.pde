void drawArrow(PVector start, PVector end)
{
  PVector arrow = end.copy().sub(start).setMag(10).rotate(TAU/2);
  PVector arrow2 = arrow.copy().rotate(-TAU/8);
  arrow.rotate(TAU/8);
  line (start.x,start.y,end.x,end.y);
  line (end.x,end.y,end.x+arrow.x,end.y+arrow.y);
  line (end.x,end.y,end.x+arrow2.x,end.y+arrow2.y);
}
