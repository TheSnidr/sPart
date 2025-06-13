/// @description
DemoText = @'Demo 5: Emitter shapes
	The standard emitter shapes: Sphere, cylinder, circle and cube';
game_set_speed(9999, gamespeed_fps);

//Create the particle system
partSystem = new spart_system([2000]);

//Create particle type
partType = new spart_type();
with partType
{
	setSprite(sprLeaf, 0, 1);
	setSize(80, 100, -1, 0, 0, 300);
	setLife(1, 1);
	setOrientation(0, 0, 360, 0, false);
	setSpeed(0, 0, 0, 0);
	setDirection(0, 0, 1, 0, false);
	setColour(c_blue, 1, c_yellow, 1, c_yellow, 1, c_blue, 1);
	setGravity(0, 0, 0, 1);
	setBlend(false, false);
}

//Create cylindrical emitter
cylinderEmitter = new spart_emitter(partSystem);
cylinderEmitter.stream(partType, 2000, -1, false)
cylinderEmitter.setRegion(matrix_build(800, 0, 300, 0, 0, 0, 1, 1, 1), 450, 450, 450, spart_shape_cylinder, ps_distr_linear, false);

//Create spherical emitter
sphericalEmitter = new spart_emitter(partSystem);
sphericalEmitter.stream(partType, 2000, -1, false)
sphericalEmitter.setRegion(matrix_build(-800, 0, 300, 0, 0, 0, 1, 1, 1), 450, 450, 450, spart_shape_sphere, ps_distr_linear, false);

//Create circular emitter
circularEmitter = new spart_emitter(partSystem);
circularEmitter.stream(partType, 2000, -1, false)
circularEmitter.setRegion(matrix_build(0, 800, 300, 0, 0, 0, 1, 1, 1), 450, 450, 200, spart_shape_circle, ps_distr_linear, false);

//Create cubical emitter
cubeEmitter = new spart_emitter(partSystem);
cubeEmitter.stream(partType, 2000, -1, false)
cubeEmitter.setRegion(matrix_build(0, -800, 300, 0, 0, 0, 1, 1, 1), 450, 450, 450, spart_shape_cube, ps_distr_linear, false);