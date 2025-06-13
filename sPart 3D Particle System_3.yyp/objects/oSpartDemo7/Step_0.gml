/// @description Update particle system
event_inherited();

explosionTimer = floor(partSystem.time / 1.5);
if explosionTimer != prevExplosionTime
{
	prevExplosionTime = explosionTimer;
	
	debrisEmitter.burst(debrisType, 15, true);
	smokeEmitter.burst(smokeType, 40, true);
	explosionEmitter.burst(explosionType, 20, true);
	traceEmitter.burst(traceType, 40, true);
}