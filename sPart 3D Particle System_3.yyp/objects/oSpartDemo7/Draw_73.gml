/// @description Draw particle system
event_inherited();

//Always draw particles last (because of alpha testing and stuff)
partSystem.draw(delta_time / 1000000);