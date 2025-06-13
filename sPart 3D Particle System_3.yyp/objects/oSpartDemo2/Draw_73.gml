/// @description Draw particle system

//In this case, I want to draw the particles before drawing the ground, since the ground has partial transparency
partSystem.draw(delta_time / 1000000);

//Draw ground
draw_sprite_ext(texGround, 0, 0, 0, 5, 5, 0, c_white, 1);
