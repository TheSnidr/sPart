/// @description
//Draw skybox
draw_clear(c_black);
shader_set(sh_spart_demo_skybox);
gpu_set_zwriteenable(false);
gpu_set_texfilter(true);
gpu_set_cullmode(cull_noculling);
var scale = 10000;
var skyMat = matrix_build(0, 0, 0, 30 + current_time / 1000, 30 + current_time / 1200, current_time / 1500, scale, scale, scale);
matrix_set(matrix_world, skyMat);
vertex_submit(global.modSphere, pr_trianglelist, sprite_get_texture(texSpartClouds, 0));
matrix_set(matrix_world, matrix_build_identity());
shader_reset();
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_counterclockwise);