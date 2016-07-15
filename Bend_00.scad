$fn=32;
length = 90;
angle = 45;
radius = 16;
inner_radius_start = 7.25;
inner_radius_end = 9;

torus_radius = length / (angle/180*PI);
cube_n = torus_radius * 2;
cube_h = radius * 2;

inner_radius_delta = inner_radius_end - inner_radius_start;

module lower_cut()
{
    translate([-cube_n*1, -cube_n*1, -cube_h/2])
    {
        rotate([0,0,0])
            cube([cube_n, cube_n*2, cube_h]);
    }
}

module upper_cut()
{
    translate([-cube_n*1, -cube_n*1, -cube_h/2])
    {
        rotate([0,0,0])
            cube([cube_n*2, cube_n, cube_h]);
    }
}

module angle_cut_end(a)
{
    translate([0,0,-cube_h/2])
    {
        rotate([0,0,a])
            cube([cube_n, cube_n, cube_h]);
    }
}

module angle_cut_start(a)
{
    translate([0,0,-cube_h/2])
    {
        rotate([0,0,90+a])
            cube([cube_n, cube_n, cube_h]);
    }
}

module torus_cutout_a()
{
    rotate_extrude()
    translate([torus_radius, 0, 0])
    circle(r=inner_radius_start);
}

module torus_main_a()
{
    difference()
    {
        // torus
        rotate_extrude()
        translate([torus_radius, 0, 0])
        circle(r=radius);
    
        lower_cut();
        upper_cut();
        angle_cut_end(-angle);
        
        torus_cutout_a();
    }
}

module bend_main_a()
{
    rotate([90,90,0])
        translate([0,-torus_radius,0])
            torus_main_a();
}

module tapered_bore(num_segs)
{
    union()
    {
        for (n = [1:num_segs])
        {
            difference()
            {
                difference() {
                    rotate_extrude()
                    translate([torus_radius, 0, 0])
                    circle(r=radius);
    
                    rotate_extrude()
                    translate([torus_radius, 0, 0])
                    circle(r=inner_radius_start+(n/num_segs)*inner_radius_delta);
                }
            
                angle_cut_start(-angle * ((n-1)/num_segs));
                angle_cut_end(-angle * (n/num_segs));
            }
        }
    }
}

module torus_main_b(num_segs)
{
    difference()
    {
        tapered_bore(num_segs);
        lower_cut();
        upper_cut();
    }
}

module bend_main_b(num_segs)
{
    rotate([90,90,0])
        translate([0,-torus_radius,0])
            torus_main_b(num_segs);
}

function z_offset() = (torus_radius + radius) * sin(angle);
echo("z_offset",z_offset());

microns = 300.0;
microns_per_mm = 1000.0/microns;
seg_res = 0.01; // in %
function num_bend_segs(seg_res) = (length * microns_per_mm) * seg_res;
echo("num_segs:",num_bend_segs());

translate([0,0,z_offset()])
    bend_main_b(false?num_bend_segs(0.1):2);
