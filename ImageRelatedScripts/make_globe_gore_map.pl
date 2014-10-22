#!/usr/bin/perl

use Gimp;
use Gimp::Fu;

register "make_globe_gore_map",
         "Create a globe gore map from a cylindrical map.",
         <<ENDOFHELP
http://www.vendian.org/mncharity/dir3/planet_globes/

Given a flat horizontal RGB image which is the cylindrical projection map
of a sphere (a planet, etc), creates an interrupted sinusoidal gore map,
suitable for printing, cutting out, and bending into a paper globe.

It runs _very_ slowly.
(e.g. hour-ish)
(I used an inefficient (but portable) mechanism to access the pixels.
 gimp-drawable-{get,set}-pixel )

Comments encouraged,
Mitchell Charity <mcharity\@vendian.org>
ENDOFHELP
,
         "Mitchell Charity <mcharity\@vendian.org>",
         "(c)2001 Mitchell Charity - GPL.",
         "20011115",  # the date this script was written (YYYYMMDD)
         N_"<Image>/Filters/Render/Make Globe...",
#         N_"<Image>/Make Globe...",
         "RGB*",
         [
         # argument type, switch name	, a short description	, default value, extra arguments
          [PF_INT	, "n_gores"	, "The number of gores to use. (e.g. 4,8,12,24,etc)", 12],
#          [PF_RADIO	, "alignment"	, "Gore alignment",  0, [inline => 0, staggered => 1]],
         ],
         sub {

   my($image,$drawable,$n_gores,$staggeredp)=@_;
   $staggeredp = 0;

   my $gore_w = $image->width  / $n_gores;
   my $gore_h = $image->height / 2;
   my $gore_half_w = $gore_w / 2;

   my $gore_h_top = rint($gore_h);
   my $gore_h_bot = $image->height - $gore_h_top;

   my @x_breakpoints;
   for(my $i = 0; $i < ($n_gores * 2); $i++) {
       my $x = $i * $gore_half_w;
       $x = rint($x);
       push(@x_breakpoints, $x);
   }
   my $w_leftmost = $x_breakpoints[1] - $x_breakpoints[0];
   push(@x_breakpoints,$image->width);
   push(@x_breakpoints,$image->width + $w_leftmost);

   my $output_width  = $image->width + ($staggeredp ? $w_leftmost : 0);
   my $common_height = $image->height;

   my $img = Image->new($output_width, $common_height, RGB);
   my $bgl = Layer->new($img, $output_width, $common_height, RGB_IMAGE,
			"Background", 100, NORMAL_MODE);
   $img->add_layer($bgl,0);
   $bgl->drawable_fill(WHITE_IMAGE_FILL);

   my $res = $image->width / 10;
   $img->set_resolution($res,$res);
   
   my $lay;
   my $new_layer = sub {
       my($name) = @_;
       $lay = Layer->new($img, $output_width, $common_height, RGBA_IMAGE,
			 $name, 100, NORMAL_MODE);
       $img->add_layer($lay,-1);
       $lay->drawable_fill(TRANS_IMAGE_FILL);
   };

   $img->display_new();
   Gimp->progress_init("Making globe gores...", -1);
   $img->undo_push_group_start;

   my $update = sub {
       $lay->update(0,0,$img->width,$img->height);
       Gimp->displays_flush();
       Gimp->progress_update($_[0]);
   };

   for(my $i = 0; $i < $n_gores; $i++) {
       &$new_layer("Gore ".($i+1));

       my $x0 = shift @x_breakpoints;
       my $x1 = shift @x_breakpoints;
       my $x2 = $x_breakpoints[0];
       my $x3 = $x_breakpoints[1];
       my $w0 = $x1 - $x0;
       my $w1 = $x2 - $x1;
       my $w2 = $x3 - $x2;
       my($BLx,$BLw) = $staggeredp ? ($x1,$w1) : ($x0,$w0);
       my($BRx,$BRw) = $staggeredp ? ($x2,$w2) : ($x1,$w1);
       my $BRxout = $BRx;
       ($BRx,$BRw) = (0,$w_leftmost) if $staggeredp && $i == ($n_gores - 1);

       &$update($i/$n_gores);
       &draw_half_gore($drawable,$x0,0,$w0,$gore_h_top,$lay,$x0,0, 'TL');
       &$update(($i+0.25)/$n_gores);
       &draw_half_gore($drawable,$x1,0,$w1,$gore_h_top,$lay,$x1,0, 'TR');
       &$update(($i+0.5)/$n_gores);
       &draw_half_gore($drawable,$BLx,$gore_h_top,$BLw,$gore_h_bot,$lay,$BLx,$gore_h_top, 'BL');
       &$update(($i+0.75)/$n_gores);
       &draw_half_gore($drawable,$BRx,$gore_h_top,$BRw,$gore_h_bot,$lay,$BRxout,$gore_h_top, 'BR');
   }

   &$update(1);

   $img->undo_push_group_end;
   ();
};

exit main;

sub draw_half_gore {
    my($in,$x,$y,$w,$h,$out,$outx,$outy,$quarter) = @_;
    my $tipattop  = $quarter =~ /T/;
    my $tipatleft = $quarter =~ /R/;
    for(my $row = 0; $row < $h; $row++) {
	my $from_tip = ($tipattop ? ($h - $row) : ($row + 1));
	my $row_w = &rint($w * cos($from_tip / $h * (3.141526/2)));
	$row_w = 1 if $row_w == 0;
	my $col_spread = $w / $row_w;
	my $col_offset = $tipatleft ? 0 : ($w - $row_w);
	for(my $col = 0; $col < $row_w; $col++) {
	    my $ix = $x + int($col * $col_spread);
	    my $ox = $outx + $col_offset + $col;
	    my $iy = $y + $row;
	    my $oy = $outy + $row;
	    my @pix = &Gimp::gimp_drawable_get_pixel($in,$ix,$iy);
	    $pix[3] = 255;
	    &Gimp::gimp_drawable_set_pixel($out,$ox,$oy,\@pix);
	}
    }
}

sub sgn  ($) { $_[0] >= 0 ? 1 : -1 }
sub rint ($) { my $f = $_[0]; my $r = int($f);
	       $r += sgn($f) if abs($f - $r) >= 0.5;
	       $r; }

