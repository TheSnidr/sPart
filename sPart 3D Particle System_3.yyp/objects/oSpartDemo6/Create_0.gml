/// @description
DemoText = @'Demo 6: Rotating circular emitter
	The system supports moving emitters.
	When you move an emitter, the system will store a log of previous emitter orientations.
	New positions are not stored every step. Instead, you can define how often new positions should be logged with
	the function called spart_system_set_dynamic_interval. Positions between logged positions are linearly
	interpolated, allowing for a smooth-looking movement even with a low number of emitters.
	Press space to switch between dynamic and non-dynamically moving emitter.';

game_set_speed(9999, gamespeed_fps);

dynamic = true;

//Create the particle system
partSystem = new spart_system([500, 1000, 2000, 4000]);

//Set the update interval - this is important if you want full control over moving emitters!
partSystem.setDynamicInterval(.1);

//Create fire type
fireType = new spart_type();
with fireType
{
	setSprite(sPartFlame, 0, 1);
	setSize(250, 350, -80, 0, 0, 400);
	setLife(.7, 1.2);
	setOrientation(0, 360, 60, 0, false);
	setSpeed(150, 300, -260, 70);
	setDirection(2, 0, 1, 20, true);
	setColour(c_orange, .3, c_red, 1, c_orange, 1, c_red, 0);
	setGravity(500, 0, 0, 1);
	setBlend(true, true);
}

//Create circular emitter
circularEmitter = new spart_emitter(partSystem);
circularEmitter.stream(fireType, 3000, -1, false);
circularEmitter.setRegion(matrix_build(0, 0, 400, 0, 0, 0, 1, 1, 1), 600, 600, 0, spart_shape_circle, ps_distr_linear, false);