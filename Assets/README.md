Because the updating of Scripts and other Assets such as .FBX, it can become confusing for people looking for specific stuff,
so here I'll stipulate some important details about these:

**Character Animator Warning**: Since Geralt_v5 and Jaskier_v3 and above the new system for action
management is animation endings, therefore animation duration is now regulated via animation frames
and animation speeds, not scripting variables storing milisecond values.

**Geralt_v1**: The first version of Geralt, includes basic animations and 1 light and 1 heavy attacks.
	- Uses GeraltScript_v1 to function. This pair of .lua and .FBX is the backup for the Vertical Slice in case "_v2" isn't finished.
**Geralt_v2**: The second version of Geralt, with most of the animations and 3 light and 3 heavy different attacks.
	- Uses GeraltScript_v2 to function in build version older than 0.2.5 (not included).
**Geralt_v3**: Includes all animations + requested modifications in some of them.
	- Uses GeraltScript_v3.
**Geralt_v4**: All animations + new medium_attack animations.
	- Uses GeraltScript_v7 tp v12.
**Geralt_v5**: Knocknack, Stun, Death, and Stand Up Animations.
	- Uses GeraltScript_v13 and above.
	
**Jaskier_v0**: Geralt_v3 with the name changed.
- Uses JaskierScript_v0.
**Jaskier_v1**: Vertical Slice Jaskier, basic animations (no abilities).
	- Uses JaskierScript_v1.
**Jaskier_v2**: All animations + new medium_attack animations.
	- Uses JaskierScript_v3 to v8.
**Jaskier_v3**: Knocknack, Stun, Death, and Stand Up Animations.
	- Uses JaskierScript_v9.
	
**GeraltScript_v1**: With Geralt_v1.
**GeraltScript_v2**: Only up to build 0.2.4 with Geralt_v2.
**GeraltScript_v3**: First varied namespaces (0.2.5 and up) with Geralt_v3.
**GeraltScript_v4**: New upgraded namespaces, **works with 0.3.1** (0.3.0 and 0.3.1) with Geralt_v3.
**GeraltScript_v4.5**: Dani's new Scripting Functions (0.3.2 and 0.3.3) with Geralt_v3.
**GeraltScript_v5**: New version made to sinchronize with Jaskier (Experimental, should not compile)
**GeraltScript_v6**: Script adapted to work with new Scripting and all features from 0.4.1 and above.
**GeraltScript_v7**: Geralt new 3 attack system, up to 0.4.2.6.
**GeraltScript_v8**: New Animation functions, since 0.4.3.0.
**GeraltScript_v9**: Character Slash Particles and Audio, since 0.4.3.0.
**GeraltScript_v10**: OnCollisionEnter now is capable of being a damage source.
**GeraltScript_v11**: Changed all velocities because of dt bug, new items, and attack velocity changes, since 0.5.0.
**GeraltScript_v12**: Simplified combos for testing.
**GeraltScript_v13**: New Geralt FBX, animations, etc.
**GeraltScript_v14**: New collider attack sizes + Audios.
**GeraltScript_v14_5**: Added Potion Particles Management.
**GeraltScript_v15**: New Child GO setup + animation/audio "library" system.
**GeraltScript_v16**: Character Speeds Polish (Faster).
**GeraltScript_v17**: Character Polish + Reworked Some Core Functions (Knockback Fixes).
**GeraltScript_v17_5**: GeraltScript_17 with some test code about camera rotation + controller inputs (DO NOT USE).

**JaskierScript_v0**: Straight up copy of Geralt Code.
**JaskierScript_v1**: Jaskier from the Vertical Slice 2. Movement, evade, basic attacks.
**JaskierScript_v2**: Script adapted to work with new Scripting and all features from 0.4.1 and above.
**JaskierScript_v3**: Jaskier cleanup of geralt code, new 3 attack system, and song system + abilities, up to 0.4.2.6.
**JaskierScript_v4**: New Animation functions, since 0.4.3.0.
**JaskierScript_v5**: Character Slash Particles and Audio, since 0.4.3.0.
**JaskierScript_v6**: OnCollisionEnter now is capable of being a damage source.
**JaskierScript_v7**: Changed all velocities because of dt bug, new items, and attack velocity changes, since 0.5.0.
**JaskierScript_v8**: Simplified combos and added new particles.
**JaskierScript_v9**: New Jaskier FBX, animations, etc. + Ability and Ultimate Particles.
**JaskierScript_v10**: New collider attack sizes + Audios.
**JaskierScript_v10_5**: Added Potion Particles Management.
**JaskierScript_v11**: New Child GO setup + animation/audio "library" system.
**JaskierScript_v12**: Character Speeds Polish (Faster).
**JaskierScript_v13**: Character Polish + Reworked Some Core Functions (Knockback Fixes).