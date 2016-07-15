$fn = 512;
hole_r_A = 5.5;
hole_r_B = 5.0;
tube_h = 18/33*1000;
bottom_h = 257.4;
top_h = 288.0;
inner_cyl_h = 16.0;
inner_cyl_w = 4.0;
tube_r = 16.0;
hole_x_off = tube_r/2;
extra = 0.1;

module shak_all()
{
    module rotcy(r)
    {
        rotate(90, [0,1,0]) { cylinder(r = r, h = hole_x_off*2+extra, center = true); }
    }

    difference()
    {
            // main cylinder
            cylinder(r = tube_r, h = tube_h, center = false);
    
            // inner bore, upper taper
            translate([0,0,-extra+taper_bot_h]) {
                cylinder(r1 = inner_rad_mid, r2 = inner_rad_top, h = tube_h-taper_bot_h+(extra*2), center = false);
            }

            // inner bore, lower taper
            translate([0,0,-extra]) {
                cylinder(r1 = inner_rad_bot, r2 = inner_rad_mid, h = taper_bot_h+(extra), center = false);
            }

            // finger holes
            translate([hole_x_off,0,hole_1_v]) { rotcy(hole_r_A); }
            translate([hole_x_off,0,hole_2_v]) { rotcy(hole_r_A); }
            translate([hole_x_off,0,hole_3_v]) { rotcy(hole_r_B); }
            translate([hole_x_off,0,hole_4_v]) { rotcy(hole_r_A); }
            translate([-hole_x_off,0,hole_5_v]) { rotcy(hole_r_A); }
    
            // utaguchi cuts
            translate([16,-25,tube_h-12.5]) {
                rotate(-30,[0,1,0]) {
                    cube(size = 50, center = false);
                }
            }
            translate([-20,0,tube_h+22.5]) {
                rotate(-6,[0,1,0]) {
                    cube(size = 50, center = true);
                }
            }
        
        taper_bot_h = 90;
        inner_rad_bot = 9;
        inner_rad_mid = 14.5/2;
        inner_rad_top = 10;
        hole_4_v = 9.4/33*1000;
        hole_3_v = hole_4_v - 1.8/33*1000;
        hole_2_v = hole_3_v - 1.8/33*1000;
        hole_1_v = hole_2_v - 1.8/33*1000;
        hole_5_v = hole_4_v + 1.2/33*1000;
    }
}

module outer_ring(r_offset, remove)
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
            translate([0,0,bottom_h]) { outer_ring(0.0, false); }
        }
    }
}

module shak_bottom()
{
    difference ()
    {
        // render all
        shak_all();
        
        // take away top MINUS inner cylinder height
        translate([0,0,bottom_h+inner_cyl_h]) {
            cylinder(r = tube_r+extra, h = top_h-inner_cyl_h+extra, center = false);
        }
        
        // take away outer ring of inner cylinder
        translate([0,0,bottom_h]) { outer_ring(0.3, true); }
    }
}




//shak_all();
//shak_top();
shak_bottom();

//outer_ring(0.0, false);
//outer_ring(0.3, true);
