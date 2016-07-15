include <Shak_Experiment_Header_00.scad>
use <Bend_Experiment_00.scad>

circle_radius = 16;

function z_offset() = (torus_radius() + circle_radius) * sin(bend_arc_angle>90?90:bend_arc_angle);
echo(z_offset());

module bend(num_segs,bore_only)
{
    difference()
    {
        if (!bore_only)
            torus(circle_radius);

        bend_bore_solid(num_segs);
    
        angle_cut(270-bend_arc_angle,circle_radius);
    
        cube_t_length = (torus_radius()+circle_radius)/2;
        quadrant_cut([cube_t_length,cube_t_length,0],circle_radius);
        quadrant_cut([-cube_t_length,cube_t_length,0],circle_radius);
        if (bend_arc_angle <= 90)
            quadrant_cut([-cube_t_length,-cube_t_length,0],circle_radius);
    }
}

translate([-torus_radius(),0,z_offset()]) rotate([90,0,0]) bend(3,false);
