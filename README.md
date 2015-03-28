# GameCheetah
GameCheetah is a AS3 SWC library created for the purpose of optimizing workflow in prototype game design using FlashDevelop or FlashBuilder.

[Main Site](http://www.gamecheetah.net)

[Getting Started](http://gamecheetah.readthedocs.org)

[Documentation](http://www.gamecheetah.net/docs/v1.1)

[Demos](http://www.gamecheetah.net/demos)


##Changes:
	
###v1.2
- may break some v1.1 code
- improved UI to be more user-friendly
- allowed upper-case to be used for tag names
- removed TextStyle class
- replaced MinimalComps components with custom components
- new Renderable.setTransformAnchorToCenter() method
- rewrite of Designer package
- modifications and clean-up to Engine class
- allow multiple Engines to be spun off
- each Space now has an "engine" property
- tweaks and glitch fixes to Space class (callback ordering)
- tweaks and glitch fixes to Engine class (event listeners)
- exposed <Space>.remove() method
- renamed <Clip>.complete to <Clip>.completed
- renamed Engine.instance to Engine.main

###v1.1
- fixed home icon dragging unresponsiveness
- fixed snap to grid misalignment
- fixed graphics and spaces menus initial values
- fixed designer not displaying missing classes
- fixed space editor 'start location' showing too many digits
- fixed support for quadtree optimization - bug where bins is always 1
- fixed support showing quadtree list structure
- fixed major bug with not correctly scaling space bounds in designer
- fixed start position not setting with the editor
- fixed clip frame not changing immediately
- fixed credits glitches
- added option to force tween to completion upon stopping
- added better support for manually adjusting quadtree depth
- added quadtree performance metrics
- cleaned up designer code
- added ability save grid info for each space
- improved support for Space.reset() - new onReset() method
- fixed some behaviour discrepancies of Space.reset()
