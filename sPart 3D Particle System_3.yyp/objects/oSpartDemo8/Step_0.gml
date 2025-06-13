/// @description Update particle system
event_inherited();

//Move vehicle
speed -= sign(speed) * min(abs(speed), 1);
speed += 5 * (keyboard_check(vk_up) - keyboard_check(vk_down));
speed = clamp(speed, -15, 50);
direction += sign(speed) * sqrt(abs(speed)) * (keyboard_check(vk_left) - keyboard_check(vk_right));

//Emit smoke particles
smokeEmitter.stream(smokeType, 10 + 2 * abs(speed), -1, true);
smokeEmitter.setRegion(matrix_build(x, y, 30, 0, 0, direction, 1, 1, 1), 0, 0, 0, spart_shape_sphere, ps_distr_linear, true);