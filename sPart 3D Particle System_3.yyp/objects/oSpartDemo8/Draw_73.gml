/// @description Draw particle system
event_inherited();

//Draw ground
draw_sprite_ext(texGround, 0, 0, 0, 5, 5, 0, c_white, 1);
matrix_set(matrix_world, matrix_build(x, y, 0, 0, 0, direction - 90, 130, 130, 130));
vertex_submit(modVan, pr_trianglelist, sprite_get_texture(texVan, 0));
matrix_set(matrix_world, matrix_build_identity());

//Always draw particles last (because of alpha testing and stuff)
partSystem.draw(delta_time / 1000000);