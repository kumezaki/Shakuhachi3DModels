$fn=64;
x = 2.5;
y = 20;
rad_circle = (x*x + y*y) / (2*x);
tube_r = 16;
xy_cube = (rad_circle*2+tube_r)*2;
extra = 0.1;

function uta_x() = x;
function uta_y() = y;

module uta_torus()
{
    rotate_extrude()
        translate([rad_circle+tube_r, 0, 0])
            circle(r=rad_circle);
}

module uta_cut_cube(z)
{
    translate([0,0,z])
        cube([xy_cube,xy_cube,rad_circle], center=true);
}

module uta_cut()
{
    difference()
    {
        uta_torus();
        uta_cut_cube(-rad_circle/2);
    }
}

module uta_main()
{
    difference ()
    {
        translate([0,0,extra])
            cylinder(h = y-extra, r = tube_r+x);
        cylinder(h = y+extra, r = tube_r);
        uta_cut();
    }
}

uta_main();
