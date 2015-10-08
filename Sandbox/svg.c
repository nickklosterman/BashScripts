/*********************************************************
 * svg_box.c
 *
 * Generate an SVG file for a box.
 *
 * Author Mike Field <hamster@snap.net.nz>
 *
 ********************************************************/
//form http://hamsterworks.co.nz/mediawiki/index.php/Svg_box
#include <stdio.h>

/*******************************************************************
 * Settings that control the size of the box - set as static
 * values because I can't be bothered with argument parsing
 *******************************************************************/
/* Box dimensions (int 1/10ths of a mm, and how many mitres to have, divided by two */
static int w = 6000, div_w = 10;
static int h = 2500, div_h = 5;
static int d =  500, div_d = 0;

/* How big the corner mitres are, in 1/10ths of a mm */
static int corner = 150;
/* Thickness for the material (depth of the mitres) in 1/10ths of a mm */
static int thick = 30;

/* Frame around the sides panels */
static int frame = 50;

/* Fudge Factor for kerf (width of cuts) - must be even as it is divided by two */
static int cut_width = 2;

/*******************************************************************/
/* For getting the correct space characters in the polyline object */
static int polyFirst;
/*******************************************************************/

static void PolyStart(void) {
  printf("<polyline points=\"");
  polyFirst = 1;
}

static void PolyPoint(int x, int y) {
  if(!polyFirst)
    printf(" ");
  polyFirst = 0;
  printf("%i,%i",x,y);
}

static void PolyEnd(void) {
  printf("\" fill=\"none\" stroke=\"black\" stroke-width=\"3\" />\r\n");
}

void MitrePanel(int x, int y, int w, int h, int corner_size,  int div_x, int div_y, int thick, int invertX, int invertY) {
  int a,b,i,d, half_cut;
  x = x-w/2+ (invertX ? thick : 0);
  y = y-h/2+ (invertY ? thick : 0);
  PolyStart();
  /////////////////////////////////
  // Top side
  /////////////////////////////////
  PolyPoint(x,y);
  x += corner_size- (invertX ? thick : 0);
  half_cut = (invertY ? -cut_width/2 : cut_width/2);
  d = (invertY ? -1 : 1);
  PolyPoint(x+half_cut,y);
  y += thick *d; d = -d;
  PolyPoint(x+half_cut,y);
  half_cut = -half_cut;

  // All but the center one
  a = (w-2*corner_size) / (2*div_x+1);
  // the center one
  b = w-2*corner_size-a*(2*div_x);

  for(i = 0; i < div_x; i++)
    {
      x += a;
      PolyPoint(x+half_cut,y);
      y += thick *d; d = -d;
      PolyPoint(x+half_cut,y);
      half_cut = -half_cut;
    }


  x+= b;
  PolyPoint(x+half_cut,y);
  y += thick *d; d = -d;
  PolyPoint(x+half_cut,y);
  half_cut = -half_cut;

  for(i = 0; i < div_x; i++)
    {
      x += a;
      PolyPoint(x+half_cut,y);
      y += thick *d; d = -d;
      PolyPoint(x+half_cut,y);
      half_cut = -half_cut;
    }

  x += corner_size- (invertX ? thick : 0);
  PolyPoint(x,y);

  /////////////////////////////////
  // Right Side
  /////////////////////////////////
  half_cut = (invertX ? -cut_width/2 : cut_width/2);
  y += corner_size - (invertY ? thick : 0);

  d = (invertX ? 1 : -1);
  PolyPoint(x,y+half_cut);
  x += thick *d; d = -d;
  PolyPoint(x,y+half_cut);
  half_cut = -half_cut;

  // All but the center one
  a = (h-2*corner_size) / (2*div_y+1);
  // the center one
  b = h-2*corner_size-a*(2*div_y);

  for(i = 0; i < div_y; i++)
    {
      y += a;
      PolyPoint(x,y+half_cut);
      x += thick *d; d = -d;
      PolyPoint(x,y+half_cut);
      half_cut = -half_cut;
    }


  y += b;
  PolyPoint(x,y+half_cut);
  x += thick *d; d = -d;
  PolyPoint(x,y+half_cut);
  half_cut = -half_cut;

  for(i = 0; i < div_y; i++)
    {
      y += a;
      PolyPoint(x,y+half_cut);
      x += thick *d; d = -d;
      PolyPoint(x,y+half_cut);
      half_cut = -half_cut;
    }

  y += corner_size - (invertY ? thick : 0);
  PolyPoint(x,y);

  /////////////////////////////////////////////////////
  // bottom Side
  /////////////////////////////////////////////////////
  half_cut = (invertY ? cut_width/2 : -cut_width/2);
  x -= corner_size-(invertX ? thick : 0);

  d = (invertY ? 1 : -1);
  PolyPoint(x+half_cut,y);
  y += thick *d; d = -d;
  PolyPoint(x+half_cut,y);
  half_cut = -half_cut;

  // All but the center one
  a = (w-2*corner_size) / (2*div_x+1);
  // the center one
  b = w-2*corner_size-a*(2*div_x);

  for(i = 0; i < div_x; i++)
    {
      x -= a;
      PolyPoint(x+half_cut,y);
      y += thick *d; d = -d;
      PolyPoint(x+half_cut,y);
      half_cut = -half_cut;
    }


  x -= b;
  PolyPoint(x+half_cut,y);
  y += thick *d; d = -d;
  PolyPoint(x+half_cut,y);
  half_cut = -half_cut;

  for(i = 0; i < div_x; i++)
    {
      x -= a;
      PolyPoint(x+half_cut,y);
      y += thick *d; d = -d;
      PolyPoint(x+half_cut,y);
      half_cut = -half_cut;
    }

  x -= corner_size-(invertX ? thick : 0);
  PolyPoint(x,y);

  /////////////////////////////////////////////////////
  // Left side
  /////////////////////////////////////////////////////
  half_cut = (invertX ? cut_width/2 : -cut_width/2);
  y -= corner_size-(invertY ? thick : 0);

  d = (invertX ? -1 : 1);
  PolyPoint(x,y+half_cut);
  x += thick *d; d = -d;
  PolyPoint(x,y+half_cut);
  half_cut = -half_cut;

  // All but the center one
  a = (h-2*corner_size) / (2*div_y+1);
  // the center one
  b = h-2*corner_size-a*(2*div_y);

  for(i = 0; i < div_y; i++)
    {
      y -= a;
      PolyPoint(x,y+half_cut);
      x += thick *d; d = -d;
      PolyPoint(x,y+half_cut);
      half_cut = -half_cut;
    }


  y -= b;
  PolyPoint(x,y+half_cut);
  x += thick *d; d = -d;
  PolyPoint(x,y+half_cut);
  half_cut = -half_cut;

  for(i = 0; i < div_y; i++)
    {
      y -= a;
      PolyPoint(x,y+half_cut);
      x += thick *d; d = -d;
      PolyPoint(x,y+half_cut);
      half_cut = -half_cut;
    }

  y -= corner_size - (invertY ? thick : 0);
  PolyPoint(x,y);
  PolyEnd();
}

void StartDoc(int w, int h) {
  w = (w+99)/100*100;
  h = (h+99)/100*100;
  printf("<?xml version=\"1.0\" standalone=\"no\"?>\r\n");
  printf("<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\r\n");
  printf("<svg width=\"%icm\" height=\"%icm\" viewBox=\"0 0 %i %i\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">\r\n", w/100, h/100, w,h);

}

void EndDoc(void) {
  printf("</svg>\r\n");
}

int main(int argc, char *argv[])
{
  StartDoc(frame*3+w+d,frame*3+h+d);


  MitrePanel(frame+w/2,        frame+h/2,         w, h, corner, div_w, div_h, thick,0,0);
  MitrePanel(frame+w+frame+d/2,frame+h/2,         d, h, corner, div_d, div_h, thick,1,0);
  MitrePanel(frame+w/2,        frame+h+frame+d/2, w, d, corner, div_w, div_d, thick,1,1);

  EndDoc();
  return 0;
}
