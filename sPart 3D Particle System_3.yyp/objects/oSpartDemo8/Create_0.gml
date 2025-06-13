/// @description
DemoText = @'Demo 8: Car exhaust
	Demonstrates emitting smoke from a moving vehicle.
	Move the vehicle with the arrow keys!';
game_set_speed(30, gamespeed_fps);

var temp = spart_load_obj_to_buffer("sPart/Van.obj");
modVan = vertex_create_buffer_from_buffer(temp, global.sPartDebugFormat); 
buffer_delete(temp);

//Create the particle system
partSystem = new spart_system([200, 400, 800, 1200, 3000, 8000]);
partSystem.setDynamicInterval(.15)

//Create smoke type
smokeType = new spart_type();
with smokeType
{
	setSprite(sPartSmoke, 0, 1);
	setSize(64, 128, 400, 0, 0, 1000);
	setLife(1, 1.2);
	setOrientation(0, 360, 100, -30, false);
	setSpeed(400, 500, 0, 0);
	setDirection(-1, 0, 0.3, 0, false);
	setColour(c_black, 0.6, c_dkgray, 0.5, c_dkgray, 0.4, c_dkgray, 0);
	setGravity(200, 0, 0, 1);
	setBlendExt(bm_src_alpha, bm_inv_src_alpha, false);
}

//Create emitter
smokeEmitter = new spart_emitter(partSystem);
smokeEmitter.stream(smokeType, 10, -1, false);