#Adding Game Logic
Now to the fun part! Trust me. Trust me. Why WON'T YOU TRUST ME!!

OKay, time to _Get_ serious.

Yes writing docs is very hard work, (but I'm over it now...) OR NOT?

Oh boy, this is going to be a long section...

GameCheetah's philosophy is that each colorful thing should take care of itself. By colorful thing, I mean a _Graphic_, and by taking care of itself, I mean managing much of its own logic.

Don't you hate it when others take charge of what you do?

##Overrides
When extending from the _Entity_ class there are methods that can be overwritten to handle game events, thus managing the entity's behavior. Oh yeah, before I forget, there's no need to call the super class method for any override prefixed with _on*_. This ensures, you can't possibly be doing it wrong (unless you start calling the useless super method)...

###onActivate()
This gets called as soon as the _Entity_ makes it on screen. Of course, you may think, why would I need this? I call just call stuff as soon as I create the Entity. True, you could, but this provides a way to handle initialization logic of Entities created using the Designer.

###onDeactivate()
This gets called at the beginning of the next frame when an entity is marked to be taken off the screen (this frame). This provides a way to do some clean-up operations when entities get removed.

###onMouseUp()
This gets called when the mouse releases on the entity. Remember the ```mouseEnabled``` property must be true for the _Entity_, and it's containing _Space_ if you want to use this override.

###onMouseDown()
This gets called when the mouse presses on the entity. Remember the ```mouseEnabled``` property must be true for the _Entity_, and it's containing _Space_ if you want to use this override.

###onMouseOver()
This gets called when the mouse initially hovers or "rolls-over" the entity. Remember the ```mouseEnabled``` property must be true for the entity, and it's containing _Space_ if you want to use this override.

###onMouseOut()
This gets called when the mouse moves out of the entity if it is currently hovering over the entity. Don't believe I need to keep repeating myself.

###onCollision(_other:Entity_)
This gets called whenever the entity collides with another entity. This method will be called by both colliding entities. Collisions are kinda complicated to set-up so please see the _"Checking for Collisions"_ section.

###onMove(_dx:int_, _dy:int_)
Work in progress. Basically gets called if the final position of an entity at the current frame differs from the previous frame. Intended to be use to handle collision detection with walls, so if you find another use for this method please let me know on how it can be improved!

##Further Notes
Here are a few extra things to keep in mind when adding game logic:

When creating an _Entity_ through the static method ```Engine.createEntity(..)``` it will not get added to the update or rendering loop until the NEXT frame. Luckily, ```onActivate``` does gets called exactly after it does gets added.

Pretty dumb, right? Actually, it's much easier to do clean-ups and initialize at the start of the frame then in the middle.

Imagine, you create an entity during an ```onUpdate()``` callback of another entity. You have not yet initialized it, but ```onCollision()``` and ```onMouseUp()``` may get called anyways before it even gets to initialized! On top of that, it will be rendered as it is at the end of the frame without going through the proper calls, HORRENDOUS! ...and this is why ```onActivate()``` and ```onDeactivate()``` are called at the start of the next frame.

###Override Calls Order:

*Start of Frame*

1. ```onActivate()```
2. ```onDeactivate()```
3. ```onUpdate()```
4. ```onMove()```
5. ```onCollision()```
6. ```onMouseOut()```
7. ```onMouseOver()```
8. ```onMouseUp()/onMouseDown```

*End of Frame - Flash renders*