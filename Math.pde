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
