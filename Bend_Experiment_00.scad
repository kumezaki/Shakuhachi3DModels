include <Shak_Experiment_Header_00.scad>

function torus_radius() = bend_tube_length / (bend_arc_angle/180*PI);
echo(torus_radius());

radius_start = 9;
radius_end = 7.25;
radius_delta = radius_start - radius_end;

function radius_max() = radius_start;
echo(radius_max());

module torus(radius)
{
    rotate_extrude()
    translate([torus_radius(), 0, 0])
    circle(r=radius);
}

module angle_cut(cut_angle,circle_radius)
{
    translate([0,0,-(torus_radius()+circle_radius)/2])
        rotate([0,0,cut_angle])
            cube(size=(torus_radius()+circle_radius), center=false);
}

module quadrant_cut(t,circle_radius)
{
    translate(t)
        cube(size=torus_radius()+circle_radius, center=true);
}

module bend_bore_solid(num_segs)
{
    difference() {
    
        intersection() {
            for (n = [1:num_segs])
            {
                radius_offset = (n-1)/(num_segs-1)*radius_delta;
                cut_angle = -(num_segs-n)/num_segs*bend_arc_angle;
                echo(n,cut_angle,radius_offset);
                difference()
                {
                    torus(radius_max()-radius_offset);
                    angle_cut(cut_angle,radius_max());
                    if (cut_angle < -90)
                        angle_cut(-90,radius_max());
                }
            }
        }
    
        angle_cut(270-bend_arc_angle,radius_max());
    
        cube_t_length = (torus_radius()+radius_max())/2;
        quadrant_cut([cube_t_length,cube_t_length,0],radius_max());
        quadrant_cut([-cube_t_length,cube_t_length,0],radius_max());
//        quadrant_cut([-cube_t_length,-cube_t_length,0],radius_max());
    }
}

num_segs = 4;
bend_bore_solid(num_segs);
