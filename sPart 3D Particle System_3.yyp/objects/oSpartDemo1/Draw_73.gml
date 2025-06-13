/// @description Draw particle system
//Clear background (necessary for HTML5)

//Draw ground
draw_sprite_ext(texGround, 0, 0, 0, 10, 10, 0, c_white, 1);

//Always draw particles last (because of alpha testing and stuff)
partSystem.draw(1 / 30);