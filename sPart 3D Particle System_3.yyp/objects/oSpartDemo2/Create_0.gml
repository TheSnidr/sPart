/// @description
DemoText = @'Demo 2: DuckiesOfTheGameMakerDiscord
	Shows how to create 3D mesh particles, as well as how to emit secondary particles';
game_set_speed(9000, gamespeed_fps);

//Create the particle system
partSystem = new spart_system([200, 400, 800, 1200, 3000, 8000]);

//Create rubber duck type
//Note: All time values are in seconds, not in steps!
rubberDuckType = new spart_type();
with rubberDuckType
{
	setMesh("sPart/RubberDuck.obj", 20);
	setMeshLighting(c_gray, c_white, 0, -1, -1);
	setMeshRotationAxis(0, 1, 0, 360);
	setSprite(texDuck, 0, 1);
	setSize(100, 140, 0, 0, 0, 200);
	setLife(3, 4);
	setOrientation(0, 360, 360, 0, true);
	setSpeed(700, 800, 0, 0);
	setDirection(0.5, 0, 1, 0, true);
	setColour(c_white, 1);
	setGravity(200, 0, 0, -1);
	setBlend(false, false);
}

//Create fire emitter
partEmitter = new spart_emitter(partSystem);
partEmitter.stream(rubberDuckType, 8, -1, false);
partEmitter.setRegion(matrix_build_identity(), 100, 100, 0, spart_shape_sphere, ps_distr_gaussian, false);