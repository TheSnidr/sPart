/// @description
//Create a vector and rotate it around the z-axis
var V = global.vect_rotate([dist, 0, dist], [0, 1, 0], window_mouse_get_y() / window_get_height());
V = global.vect_rotate(V, [0, 0, 1], window_mouse_get_x() / 100);

camera_set_view_mat(view_camera[0], matrix_build_lookat(V[0], V[1], V[2], 0, 0, 0, 0, 0, 1));