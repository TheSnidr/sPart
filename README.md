sPart is a stateless, shader-driven 3D particle system for GameMaker.

- What does it mean by "shader-driven"? This means that the particles are controlled by a shader. You can set some general rules for the particles, but you don't get precise controls for each particle.

- What does "stateless" mean? Particles don't store their states from step to step. Their positions, their speeds, scales, sprite indices are all created on the fly using a combination of the equations of motion and "random" number generators.

This means that drawing the particles is blazing fast, at the cost of imprecise controls. The more control you try to exert over the particle generation, the slower it will run. The fastest case is a still-standing emitter that creates a constant stream of particles. The slowest case is a moving emitter that creates short bursts of particles. The still emitter will be able to draw all its particles with a single draw call, while a moving emitter needs to split up into smaller sub-emitters in order to properly draw a trail of particles, requiring more draw calls.

The documentation has not been updated properly after sPart went over to using structs. It may be updated in the future. For the time being, check out the included demos for inspiration!
