/// @description Move the emitter
event_inherited();

var xx = 0;
var yy = 1000 * cos(partSystem.time);
var zz = 450;
var xrot = 0;
var yrot = partSystem.time * 120;
var zrot = partSystem.time * 80;
var xScale = 600;
var yScale = 600;
var zScale = 0;

circularEmitter.setRegion(matrix_build(xx, yy, zz, xrot, yrot, zrot, 1, 1, 1), xScale, yScale, zScale, spart_shape_circle, ps_distr_linear, dynamic);