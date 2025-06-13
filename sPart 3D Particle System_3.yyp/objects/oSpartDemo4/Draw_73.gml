/// @description Draw particle system

//Draw ground
draw_sprite_ext(texGround, 0, 0, 0, 5, 5, 0, c_white, 1);

//Always draw particles last (because of alpha testing and stuff)
partSystem.draw(delta_time / 1000000);