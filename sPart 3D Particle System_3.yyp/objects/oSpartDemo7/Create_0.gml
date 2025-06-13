/// @description
DemoText = @'Demo 7: Explosion
	Create an explosion effect using multiple particle types and emitters';
game_set_speed(9990, gamespeed_fps);

explosionTimer = 0;
prevExplosionTime = -1;

//Create the particle system
partSystem = new spart_system([45, 1000, 2000]);

//Create explosion type
explosionType = new spart_type();
with explosionType
{
	setSprite(sPartSmoke, 0, 1);
	setSize(256, 1024, 30*128, -20*128, 0, 2000);
	setLife(0.4, 1);
	setOrientation(0, 360, 10, 0, false);
	setSpeed(40, 50, 0, 0);
	setDirection(0, 0, 1, 360, true);
	setColour(c_white, 0.8, c_orange, 1, c_orange, 1, c_black, 0);
	setGravity(30, 0, 0, 1);
	setBlend(true, true);
}

//Create smoke type
smokeType = new spart_type();
with smokeType
{
	setSprite(sPartSmoke, 0, 1);
	setSize(192, 1280, 0, 0, 0, 2000);
	setLife(1.2, 2);
	setOrientation(0, 360, 100, -30, false);
	setSpeed(100, 150, 0, 0);
	setDirection(0, 0, 1, 360, true);
	setColour(c_black, 0.5, c_orange, 0.5, c_dkgray, 1, c_black, 0);
	setGravity(50, 0, 0, 1);
	setBlendExt(bm_src_alpha, bm_inv_src_alpha, false);
}

//Create trail type (follows debris type 2)
trailType = new spart_type();
with trailType
{
	setSprite(sPartSmoke, 0, 1);
	setSize(42, 84, 1024, -128, 0, 2000);
	setLife(0.7, 1.2);
	setOrientation(0, 360, 50, 0, false);
	setSpeed(0, 0, 0, 0);
	setDirection(0, 0, 1, 360, true);
	setColour(c_orange, .5, c_gray, .5, c_dkgray, .5, c_black, 0);
	setGravity(20, 0, 0, 1);
	setBlendExt(bm_src_alpha, bm_inv_src_alpha, false);
}

//Create debris type 1
traceType = new spart_type();
with traceType
{
	setSprite(sPartTrace, 0, 1);
	setSize(100, 200, 0, 0, 0, 2000);
	setLife(0.3, 0.6);
	setOrientation(90, 90, 0, 0, true);
	setSpeed(2800, 2200, 0, 0);
	setDirection(1, 0, 0, 20, true);
	setColour(c_orange, 1, c_yellow, 1);
	setGravity(1000, 0, 0, -1);
	setBlendExt(bm_src_alpha, bm_inv_src_alpha, false);
}

//Create debris type 2
debrisType = new spart_type();
with debrisType
{
	setSprite(sprLeaf, 0, 1);
	setSize(100, 200, 0, 0, 0, 2000);
	setLife(0.5, 1.2);
	setOrientation(0, 360, 360, 0, false);
	setSpeed(3000, 5500, -1400, 0);
	setDirection(1, 0, 0, 20, true);
	setColour(c_dkgray, 1);
	setGravity(1000, 0, 0, -1);
	setStep(other.trailType, 100);
}

//Create explosion emitter
explosionEmitter = new spart_emitter(partSystem);
explosionEmitter.setRegion(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1), 400, 400, 400, spart_shape_sphere, ps_distr_linear, false);

//Create smoke emitter
smokeEmitter = new spart_emitter(partSystem);
smokeEmitter.setRegion(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1), 400, 400, 400, spart_shape_sphere, ps_distr_linear, false);

//Create debris emitter
debrisEmitter = new spart_emitter(partSystem);
debrisEmitter.setRegion(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1), 200, 200, 300, spart_shape_sphere, ps_distr_linear, false);

//Create debris emitter
traceEmitter = new spart_emitter(partSystem);
traceEmitter.setRegion(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1), 200, 200, 300, spart_shape_sphere, ps_distr_linear, false);