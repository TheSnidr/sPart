/// @description
DemoText = @'Demo 3: Outlined Campfire
	This demo shows how to make two separate emitters emit particles that are
	simulated in the exact same way. 
	A black particle emitter is draw under the fire to make the additive effect more powerful.
	With a simple trick, the black particles follow the fire particles precisely.
	By using spart_emitter_mature, you can make the emitter start with the maximum amount of particles.';
game_set_speed(30000, gamespeed_fps);

//Create the particle system
partSystem = new spart_system([1500]);

//Create smoke type
//Note: All time values are in seconds, not in steps!
smokeType = new spart_type();
with smokeType
{
	setSprite(sPartSmoke, 0, 1);
	setSize(280, 300, 6, 0, 0, 500);
	setLife(2, 3);
	setOrientation(0, 360, 0, 0, false);
	setSpeed(500, 550, -70, 0);
	setDirection(0, 0, 1, 0, false);
	setColour(c_dkgray, .1, c_dkgray, 0.1, c_dkgray, 0.2, c_gray, 0);
	setGravity(100, 0, 0, 1);
	setBlendExt(bm_src_alpha, bm_inv_src_alpha, false);
}

//Create soot type
//Note: All time values are in seconds, not in steps!
sootType = new spart_type();
with sootType
{
	setSprite(sPartFlame, 0, 1);
	setSize(380, 420, -120, 0, 0, 500);
	setLife(1.5, 2);
	setOrientation(0, 360, 40, 60, false);
	setSpeed(150, 300, -260, 70);
	setDirection(2, 0, 1, 20, true);
	setColour(make_color_hsv(0, 0, 20), 1, make_color_hsv(0, 0, 100), 1, make_color_hsv(0, 0, 100), 1, c_black, 1);
	setGravity(300, 0, 0, 1);
	setBlendExt(bm_zero, bm_inv_src_colour, false);
	setAlphaTestRef(1);
}

//Create fire type
//Note: All time values are in seconds, not in steps!
fireType = new spart_type();
with fireType
{
	setSprite(sPartFlame, 0, 1);
	setSize(380, 420, -120, 0, 0, 500);
	setLife(1.5, 2);
	setOrientation(0, 360, 40, 60, false);
	setSpeed(150, 300, -260, 70);
	setDirection(2, 0, 1, 20, true);
	setColour(c_orange, 0.2, c_red, 1., c_orange, 0.5, c_red, 0);
	setGravity(300, 0, 0, 1);
	setBlend(true, true);
	setAlphaTestRef(1);
}

//Create a soot emitter first, so that the dark background is drawn before the actual fire
sootEmitter = new spart_emitter(partSystem);
sootEmitter.stream(sootType, 120, -1, false)
sootEmitter.setRegion(matrix_build(0, 0, 150, 0, 0, 0, 1, 1, 1), 100, 100, 1, spart_shape_cylinder, ps_distr_gaussian, false);

//Create the fire emitter
fireEmitter = new spart_emitter(partSystem);
fireEmitter.stream(fireType, 120, -1, false)
fireEmitter.setRegion(matrix_build(0, 0, 150, 0, 0, 0, 1, 1, 1), 100, 100, 1, spart_shape_cylinder, ps_distr_gaussian, false);
fireEmitter.mature();

//Copy the ID of the fire emitter to the soot emitter, so that their particles are generated at the same positions.
sootEmitter.ID = fireEmitter.ID;
sootEmitter.creationTime = fireEmitter.creationTime;

//Loag log model
var mbuff = spart_load_obj_to_buffer("sPart/Campfire.obj");
modCampFire = vertex_create_buffer_from_buffer(mbuff, global.sPartDebugFormat);
buffer_delete(mbuff);