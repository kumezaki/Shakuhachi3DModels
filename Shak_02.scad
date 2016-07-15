include <Shak_Experiment_Header_00.scad>
use <Bend_Experiment_00.scad>
use <Shak_Experiment_00.scad>
use <CurvedUtaguchi.scad>

hole_r_A = 5.5;
hole_r_B = 5.0;
tube_h = 18/33*1000;
top_h = 288.0;
//bottom_h = 257.4;
bottom_h = tube_h-top_h;
inner_cyl_h = 16.0;
inner_cyl_w = 4.0;
tube_r = 16.0;
hole_x_off = tube_r/2;
extra = 0.0;

module shak_all()
{
    module main_cylinder()
    {
        union()
        {
            // main cylinder
            cylinder(r = tube_r, h = tube_h, center = false);
            
            // curved utaguchi
            translate([0,0,tube_h-uta_y()])
            uta_main();
        }
    }
    
    module rotcy(r)
    {
        rotate(90, [0,1,0]) { cylinder(r = r, h = hole_x_off*2+extra, center = true); }
    }
    
    module fingerholes()
    {
        hole_4_v = 9.4/33*1000;
        hole_3_v = hole_4_v - 1.8/33*1000;
        hole_2_v = hole_3_v - 1.8/33*1000;
        hole_1_v = hole_2_v - 1.8/33*1000;
        hole_5_v = hole_4_v + 1.2/33*1000;

        // finger holes
        translate([hole_x_off,0,hole_1_v]) { rotcy(hole_r_A); }
        translate([hole_x_off,0,hole_2_v]) { rotcy(hole_r_A); }
        translate([hole_x_off,0,hole_3_v]) { rotcy(hole_r_B); }
        translate([hole_x_off,0,hole_4_v]) { rotcy(hole_r_A); }
        translate([-hole_x_off,0,hole_5_v]) { rotcy(hole_r_A); }
    }
    
    taper_bot_h = bend_tube_length;
    inner_rad_top = 10;
    inner_rad_mid = 14.5/2;
    inner_rad_bot = 9;

    module inner_bore_upper_taper()
    {
        translate([0,0,-extra+taper_bot_h])
            cylinder(r1 = inner_rad_mid, r2 = inner_rad_top,
                    h = tube_h-taper_bot_h+(extra*2), center = false);
    }

    module inner_bore_lower_taper()
    {
        translate([0,0,-extra])
            cylinder(r1 = inner_rad_bot, r2 = inner_rad_mid,
                    h = taper_bot_h+(extra), center = false);
    }

    difference()
    {
        main_cylinder();
        
        union()
        {
            inner_bore_upper_taper();
            inner_bore_lower_taper();
        }
        
        utaguchi_cut_front();
        utaguchi_cut_back();

        fingerholes();
    }
}

module outer_ring(r_offset)
{
    cyl_h = inner_cyl_h;
    difference()
    {
        // render solid
        cylinder(r = tube_r, h = cyl_h, center = false);
        
        // remove inner portion
        translate([0,0,0])
        {
            cylinder(r = tube_r-inner_cyl_w+r_offset, h = cyl_h, center = false);
        }
    }
}

module outer_ring_deprecated(r_offset, remove)
{
    cyl_h = inner_cyl_h + (remove ? extra : 0.);
    difference()
    {
        // render solid
        cylinder(r = tube_r + (remove ? extra : 0.), h = cyl_h, center = false);
        
        // remove inner portion
        translate([0,0,(remove ? 0 : -extra)])
        {
            cylinder(r = tube_r-inner_cyl_w+r_offset, h = cyl_h + (remove ? 0 : extra*2), center = false);
        }
    }
}

uta_cut_cube_size = 50; // not sure how to calculate the exact dimensions of the cube

module utaguchi_cut_front()
{
//    cut_h = 12.5;
    cut_h = 13.5;
//    cut_angle = 30.0;
    cut_angle = 30.0;
    translate([tube_r,-(uta_cut_cube_size/2),tube_h-cut_h]) {
        rotate(-cut_angle,[0,1,0]) {
            cube(size = uta_cut_cube_size, center = false);
        }
    }
}

module utaguchi_cut_back()
{
    translate([-20,0,tube_h+22.5]) {
        rotate(-6,[0,1,0]) {
            cube(size = uta_cut_cube_size, center = true);
        }
    }
}

module shak_top()
{
    // move top down to origin
    translate([0,0,-bottom_h])
    {
        // combine top MINUS inner cylinder height w/ outer ring
        union()
        {
            difference()
            {
                // render all
                shak_all();
                        
                // take away bottom PLUS inner outer ring height
                translate([0,0,-extra]) {
                    cylinder(r = tube_r+extra, h = bottom_h+inner_cyl_h+extra, center = false);
                }
            }
    
            // add outer ring of inner cylinder
//            translate([0,0,bottom_h]) { outer_ring(0.0, false); }
            translate([0,0,bottom_h]) { outer_ring(0.0); }
        }
    }
}

module shak_bottom()
{
    difference()
    {
        // render all
        shak_all();
        
        // take away top MINUS inner cylinder height
        translate([0,0,bottom_h+inner_cyl_h]) {
            cylinder(r = tube_r+extra+uta_x(), h = top_h-inner_cyl_h+extra+1.0, center = false); // 1.0 added to height as a temporary fix
        }
        
        // take away outer ring of inner cylinder
//        translate([0,0,bottom_h]) { outer_ring(-0.2, true); }
        translate([0,0,bottom_h]) { outer_ring(-(print_microns/1000*1.5)); }
    }
}

module nakatsugi_top()
{
    difference()
    {
        shak_top();

        translate([0,0,inner_cyl_h+5])
                cylinder(r = tube_r+uta_x(), h = top_h-5, center = false);
    }
}

module nakatsugi_bottom()
{
    translate([0,0,-(bottom_h-5)])
        difference()
        {
            shak_bottom();
    
            cylinder(r = tube_r+uta_x(), h = bottom_h-5, center = false);
        }
}

// the following section is for the bent bottom

//module bend(bend_seg_scale)
//{
//    translate([0,0,z_offset()])
//        rotate([0,0,180])
//            bend_main_b(num_bend_segs(bend_seg_scale));
//}

module main_with_bend(all,num_segs)
{
    //mirror([0,0,1])
    //translate([0,0,-(bottom_h+inner_cyl_h)])
    {
        bend_offset = bend_tube_length-z_offset();
        difference()
        {
            if (all)
                shak_all();
            else
                translate([0,0,-bend_offset]) shak_bottom();
        
            translate([0,0,-bend_offset-extra])
                cylinder(r=tube_r+extra*2,h=bend_tube_length);
        
        }

		rotate([0,0,180])
			translate([-torus_radius(),0,z_offset()])
				rotate([90,0,0])
					bend(num_segs,false);
    }
}

module shak_all_bend(num_segs)
{
    main_with_bend(true,num_segs);
}

module shak_bottom_bend(num_segs)
{
    main_with_bend(false,num_segs);
}

//shak_all();
//shak_top();
//shak_bottom();

nakatsugi_top();
//nakatsugi_bottom();

// for final print (make sure to switch $fn to 256)
// num_segs = 15;
// for editing
// num_segs = 2;
//shak_all_bend(num_segs);
//shak_bottom_bend(num_segs);