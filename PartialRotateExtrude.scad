include <Shak_Experiment_Header_00.scad>

function torus_radius() = bend_tube_length / (bend_arc_angle/180*PI);
echo(torus_radius());

circle_radius = 7.5;
num_steps = 5;

module pie_slice(radius, angle, step)
{
	for(theta = [0:step:angle-step])
	{
        echo(theta);
		rotate([0,0,0])
		linear_extrude(height = radius*2, center=true)
        polygon(points = [[0,0],
                        [radius*cos(theta+step),radius*sin(theta+step)],
                        [radius*cos(theta),radius*sin(theta)]]);
	}
}

module partial_rotate_extrude(angle, radius, convex) {
    intersection () {
        rotate_extrude(convexity=convex) translate([radius,0,0]) children(0);
        pie_slice(radius*2, angle, angle/num_steps);
    }
}

bend_arc_angle = 90;
//partial_rotate_extrude(bend_arc_angle, torus_radius(), 10) circle(circle_radius);

module foo()
{
    rotate_extrude(convexity=10) translate([torus_radius(),0,0]) children(0);
}

intersection()
{
//    foo() circle(circle_radius);
//    linear_extrude(height = circle_radius*2, center=true)
//        polygon(points = [[0,0],[10,torus_radius()+circle_radius],[20,torus_radius()+circle_radius]]);
}

segments = 10;
theta_delta = bend_arc_angle/segments;
rad_start = 7.25;
rad_end = 9;
rad_diff = rad_end - rad_start;
for (i = [0:segments-1])
{
    theta = (i/segments)*bend_arc_angle;
    rad = (rad_diff * i) + rad_start;
    radius = torus_radius()+rad;
    intersection()
    {
        foo() circle(rad);
        linear_extrude(height = rad*2, center=true)
            polygon(points = [[0,0],
                [radius*cos(theta),radius*sin(theta)],
                [radius*cos(theta+theta_delta),radius*sin(theta+theta_delta)]]);
    }
}
