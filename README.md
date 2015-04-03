# GameCheetah
GameCheetah is an AS3 library designed for quickly prototyping games using FlashDevelop or FlashBuilder.

[Main Site](http://www.gamecheetah.net)

[Getting Started](http://gamecheetah.readthedocs.org)

[Documentation](http://www.gamecheetah.net/docs/v1.1)

[Demos](http://www.gamecheetah.net/demos)


##Changes:
	
###v1.2
*New features:*
- improved UI to be more user-friendly
- rewrite of Designer package
- allowed upper-case to be used for tag names
- replaced MinimalComps components with custom components
- exposed &lt;Space&gt;.remove() method
- new &lt;Renderable&gt;.setTransformAnchorToCenter() method
- allow multiple Engine instances to be created and used
- each Space now has an .engine property
- allow for swapping of Entity/Space classes in Designer without major consequences

*The following changes may break some v1.1 code:*
- removed TextStyle class
- renamed &lt;Clip&gt;.complete to &lt;Clip&gt;.completed
- renamed Engine.instance to Engine.main
- modifications and clean-up to Engine class
- rewrote caching algorithm for transformed collision mask objects (Entity class)

*The following are essential/critical bug fixes:*
- tweaks and bug fixes to Space class (callback ordering)
- tweaks and bug fixes to Engine class (event listeners)
- tweaks and bug fixes to Entity class (scaling collision bitmap)
- added ability to render point masks
- fixed bug allowing for Point collision object to be applied with transformations

*Temporarily removed features:*
- Quadtree viewer
- Debug watcher

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
