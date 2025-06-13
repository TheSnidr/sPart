/// @description
DemoText = @'Demo 4: Toy rockets
	The toy rockets fly in a sigmoid path while pointing toward their moving direction
	while emitting fire particles bakwards, and finally exploding in a huge blast.
	The particle system gives you a lot of tools to customize the movement pattern of your particles!
	Here'+"'s a stress test for you: Press space to add more particles";
game_set_speed(30000, gamespeed_fps);

//Create the particle system
partSystem = new spart_system([800, 4000, 10000]);

//Create smoke type
smokeType = new spart_type();
with smokeType
{
	setSprite(sPartSmoke, 0, 1);
	setSize(100, 150, .1, 0, 0, 300);
	setLife(1, 1);
	setOrientation(0, 360, 0, 0, false);
	setSpeed(500, 800, 0, 0);
	setDirection(-1, 0, 0, 10, true);
	setColour(c_red, 1, c_orange, 1, c_dkgray, 1, c_dkgray, 0);
	setGravity(1, 0, 0, 1);
	setBlendExt(bm_src_alpha, bm_inv_src_alpha, false);
}

//Create fireworks type
fireworksType = new spart_type();
with fireworksType
{
	setSprite(sPartFlare, 0, 1);
	setSize(200, 250, -100, 0, 0, 300);
	setLife(0.6, 0.8);
	setOrientation(0, 360, 0, 0, false);
	setSpeed(1000, 2000, -1000, 0);
	setDirection(0, 0, 1, 360, false);
	setColour(c_red, 1, c_yellow, 1, c_orange, 1, c_orange, 1, true);
	setGravity(1, 0, 0, 1);
	setBlendExt(bm_src_alpha, bm_inv_src_alpha, false);
}

//Create rocket type
rocketType = new spart_type();
with rocketType
{
	setMesh("sPart/ToyRocket.obj", 255);
	setMeshLighting(c_gray, c_white, 0, -1, -1);
	setMeshRotationAxis(1, 0, 0, 0);
	setMeshCullmode(cull_noculling);
	setSprite(texToyRocket, 0, 1);
	setSize(180, 180, 0, 0, 0, 200);
	setLife(3.0, 3.5);
	setOrientation(0, 0, 360, 0, true);
	setSpeed(1000, 1200, 0, 160);
	setDirection(0.2, 0, 1, 0, true);
	setColour(c_white, 1, c_white, 1, c_white, 1);
	setGravity(700, 0, 0, -1);
	setBlend(false, false);
	setStep(other.smokeType, 30);
	setDeath(other.fireworksType, 50);
}

//Create emitter
partEmitter = new spart_emitter(partSystem);
partEmitter.stream(rocketType, 5, -1, false)
partEmitter.setRegion(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1), 600, 600, 0, spart_shape_circle, ps_distr_gaussian, false);