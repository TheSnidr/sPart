/// @description
globalvar DemoText;
DemoText = "";

//Load skybox
global.modSphere = spart_create_sphere(32, 16, 1, 1);

global.vect_rotate = function(v, axis, radians) 
{
	//Rotates the vector v around the given axis using Rodrigues' Rotation Formula
	var a = axis;
	var c = cos(radians);
	var s = sin(radians);
	var d = (1 - c) * (a[0] * v[0] + a[1] * v[1] + a[2] * v[2]);
	return [v[0] * c + a[0] * d + (a[1] * v[2] - a[2] * v[1]) * s,
			v[1] * c + a[1] * d + (a[2] * v[0] - a[0] * v[2]) * s,
			v[2] * c + a[2] * d + (a[0] * v[1] - a[1] * v[0]) * s]


}