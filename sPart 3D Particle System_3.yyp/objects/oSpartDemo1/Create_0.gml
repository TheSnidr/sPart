/// @description
DemoText = @'Demo 1: Simple particle fountain
	Thank you for testing the sPart system!
	This is a basic particle type and emitter.
	Particles can have up to four colours, they can have animated sprites, or even 3D meshes
	There are four emitter shapes: sphere, cube, cylinder and circle
	and three distribution types: linear, gaussian and invgaussian
	Particles can emit more particles, either each step or upon death, as will be demonstrated.';
game_set_speed(30, gamespeed_fps);

//Create the particle system
partSystem = new spart_system([256, 600]);

//Create a particle type
//Note: All time values are in seconds, not in steps!
partType = new spart_type();
with partType
{
	setSprite(sPartFire, 0, 1);
	setSize(100, 140, 0, 0, 0, 200);
	setLife(2, 3);
	setOrientation(0, 360, 150, 0, true);
	setSpeed(300, 400, 0, 0);
	setDirection(1, 0, 2, 20, false);
	setColour(c_white, 0, c_green, 1, c_blue, 1, c_red, 0);
	setGravity(0, 0, 0, -1);
	setBlend(true, true);
}

//Create a particle emitter
partEmitter = new spart_emitter(partSystem);
partEmitter.stream(partType, 300, -1, false);
partEmitter.setRegion(matrix_build_identity(), 400, 400, 1, spart_shape_circle, ps_distr_linear, false);