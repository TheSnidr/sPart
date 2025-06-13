/// @description Draw particle system
draw_clear(c_black);

//Draw ground
gpu_set_tex_filter(true);
draw_sprite_ext(texGround, 0, 0, 0, 5, 5, 0, c_white, 1);

partSystem.draw(delta_time / 1000000);