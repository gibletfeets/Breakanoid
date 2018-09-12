class vec2
{
  
  float x;
  float y;
  
  vec2(float theta)
  {
   x = cos(theta);
   y = sin(theta);
  }
  
  vec2(float a, float b)
  {
    x = a; y = b;
  }
  
  String toString()
  {
    return '['+str(x)+','+str(y)+']';
  }
  
  void add (vec2 input)
  {
    x += input.x;
    y += input.y;
  }
  
  void sub(vec2 input)
  {
    x -= input.x;
    y -= input.y;
  }
  
  vec2 copy()
  {
    return new vec2(x,y);
  }
  
  void mult (float scalar)
  {
    x *= scalar;
    y *= scalar;
  }
  
  void div (float scalar)
  {
    x /= scalar;
    y /= scalar;
  }
  
  void rotate(float angle)
  {
    float x0 = x, y0 = y;
    x = (x0 * cos(angle) - y0 * sin(angle));
    y = (x0 * sin(angle) + y0 * cos(angle));
  }
  
  float heading()
  {
    return atan2(x,y);
  }
  
  float distance(vec2 a)
  {
    return robustLength(x-a.x,y-a.y);
  }
  
  float mag()
  {
    return robustLength(x,y);
  }
  
  void setMag(float input)
  {
    float mag = robustLength(x,y);
    x *= input/mag;
    y *= input/mag;
  }
  
  void normalize()
  {
    float mag = robustLength(x,y);
    x /= mag;
    y /= mag;
  }
  
  float dot(vec2 term)
  {
    return (x * term.x + y * term.y);
  }
  
  void set(float a, float b)
  {
    x = a;
    y = b;
  }
}  
  
float setSign(float a, float b)
{
  //set the sign of a to that of b
  return a*(round(abs(b)/b));
}

float robustLength (float v0, float v1)
{
  //Computes the length of an input vector <v1,v2> by avoiding floating point overflow that could normally occur while computing
  //v0^2 + v1^2
  float min, max;
  if (abs(v0) > abs (v1)) {max = v0; min = v1;}
  else                    {max = v1; min = v0;}
  return abs(max)*sqrt(1+sq(min/max));
}


vec2 reflectVector(vec2 tobeReflected, vec2 surfaceNormal)
{
  float x0 = -tobeReflected.x, x1 = surfaceNormal.x;
  float y0 = -tobeReflected.y, y1 = surfaceNormal.y;
  return new vec2(-(x0 - 2*(x0*x1 + y0*y1)*x1),-(y0 - 2*(x0*x1 + y0*y1)*y1));
}

vec2 closestPointRectangle(vec2 o, vec2 s, vec2 q)
{
    vec2 t = q.copy();
    if      (q.x < o.x - s.x)  t.x = o.x - s.x;
    else if (q.x > o.x + s.x)  t.x = o.x + s.x;
    if      (q.y < o.y - s.y)  t.y = o.y - s.y;
    else if (q.y > o.y + s.y)  t.y = o.y + s.y;
    return t;
}

vec2 closestPointEllipse(vec2 o, vec2 s, vec2 test)
{
    vec2 point = test.copy();
    point.sub(o);
    float px = abs(point.x);
    float py = abs(point.y);

    float t = TAU / 8;

    float a = s.x;
    float b = s.y;
    float x = a * cos(t);
    float y = b * sin(t);
    
    for (int i = 0; i < 3; i++)
    {
        x = a * cos(t);
        y = b * sin(t);

        float ex = (sq(a) - sq(b)) * pow(cos(t),3) / a;
        float ey = (sq(b) - sq(a)) * pow(sin(t),3) / b;

        float rx = x - ex;
        float ry = y - ey;

        float qx = px - ex;
        float qy = py - ey;

        float r = robustLength(ry, rx);
        float q = robustLength(qy, qx);

        float delta_c = r * asin((rx*qy - ry*qx)/(r*q));
        float delta_t = delta_c / sqrt(sq(a) + sq(b) - sq(x) - sq(y));

        t += delta_t;
        t = min(TAU/4, max(0, t));
  }
    point = new vec2(setSign(x, point.x), setSign(y, point.y));
    point.add(o);
    return point;
}
