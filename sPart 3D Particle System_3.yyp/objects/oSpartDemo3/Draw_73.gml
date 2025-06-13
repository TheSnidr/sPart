/// @description Draw particle system

//Draw ground
draw_sprite_ext(texGround, 0, 0, 0, 5, 5, 0, c_white, 1);

matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 60, 60, 60));
vertex_submit(modCampFire, pr_trianglelist, sprite_get_texture(texLogs, 0));
matrix_set(matrix_world, matrix_build_identity());

//Play with the particle type settings to simulate wind
xdir = cos(current_time / 600) * cos(current_time / 896 + 1) * cos(current_time / 1048 + 2);
smokeType.setGravity(200, .25 * xdir, 0, 1);
sootType.setGravity(300, .4 * xdir, 0, 1);
fireType.setGravity(300, .4 * xdir, 0, 1);

//Always draw particles last (because of alpha testing and stuff)
partSystem.draw(delta_time / 1000000 * (1 + sqr(xdir)));