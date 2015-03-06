/*Copyright (c) 2012, Martin Källman
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.*/

package gamecheetah.strix.collision.quadtree {
    
    import gamecheetah.strix.collision.Agent;
    import gamecheetah.strix.collision.Collision;
    import gamecheetah.strix.collision.error.IllegalBoundsError;
    import gamecheetah.strix.collision.error.InternalError;
    import gamecheetah.strix.notification.Notification;
	import flash.geom.Point;
	import flash.geom.Rectangle;
    
    /**
	 * @private
	 */
    internal final class TreeNode {

        private static const
            READD           : Boolean = true,
            DISCRETE_MODE   : uint = 0,
            CONTINUOUS_MODE : uint = 1;
        
        public var
			rect : Rectangle;
                
        public var
            depth    : uint,
            maxDepth : uint,
            root     : TreeNode,
            parent   : TreeNode,
            children : Vector.<TreeNode>;
        
        public var objects       : Vector.<Agent>;
		
		public var collisionChecks : uint;
        
            
        public function TreeNode(
            rect:Rectangle,
            depth:uint, maxDepth:uint,
            parent:TreeNode, root:TreeNode ) {
            
            this.rect = rect;
            
			if (this.rect == null)
			{
				trace("Treenode not defined.")
			}
			
            this.depth = depth;
            this.maxDepth = maxDepth;
            
            this.parent = parent;
            this.root = root;
            this.children = new Vector.<TreeNode>(4, true);
            
            this.objects = new Vector.<Agent>;
        }
        
		public function print(indent:String):String 
		{
			var result:String = "";
			
			var agent:Agent;
			for each (agent in objects)
			{
				result += "\n" + indent + agent.id + " : x=(" + int(agent.x) + ", " + int(agent.right) + ") y=(" + int(agent.y) + ", " + int(agent.bottom) + ")";
			}
			
			var i:uint;
			for (i = 0; i < 4; i++)
			{
				if (children[i] != null)
					result += "\n" + indent + "> [" + i + "]" + children[i].print(indent + "\t");
			}
			return result;
		}
        
        public function addObject( object:Agent, readd:Boolean=false ) : TreeNode {
            if( Quadtree.throwExceptions && !rect.containsRect(object) )
                throw new IllegalBoundsError("Attempted to insert and object with, or update an object to, illegal bounds.");
            
            //If object exceeds half-width x half-width, it straddles some axis, and must be stored here
            if ( object.width > (rect.width / 2) || object.height > (rect.height / 2) )
                return addObjectToSelf(object, readd);
            
            //If maximum depth has been reached, object must be stored here
            if( depth >= maxDepth )
                return addObjectToSelf(object, readd);
			
			//Precalculate half widths, half heights for efficiency.
			var halfWidth  : Number = rect.width / 2,
				halfHeight : Number = rect.height / 2,
				X : Number = rect.x,
				Y : Number = rect.y;
            
            var quad       : uint = 0,
                quadRect   : Rectangle = new Rectangle(X, Y, halfWidth, halfHeight);

            //Attempt to fit the object into one of the quadrants
			var qy : uint, 
				qx : uint;
            for( qy = 0; qy < 2; qy++ ) {
                for ( qx = 0; qx < 2; qx++ ) {
					quadRect.x = X + qx * halfWidth;
					quadRect.y = Y + qy * halfHeight;
  
                    if( quadRect.containsRect(object) ) {
                        if( children[quad] == null ) {
                            children[quad] = TreeNodePool.getObject(
                                new Rectangle(
                                    quadRect.x,
                                    quadRect.y,
                                    quadRect.width,
                                    quadRect.height
                                ),
                                depth+1, maxDepth,
                                this, root
                            );
                        }
                        
                        return children[quad].addObject(object);
                    }
                    
                    quad++;
                }
            }
            
            //Object did not fit into any of the quadrants
            return addObjectToSelf(object, readd);
        }

        
        private function addObjectToSelf( object:Agent, readd:Boolean=false ) : TreeNode {
            if( readd )
                return this;
            
            objects.push(object);
            
			object.onChange.addListener(
				Agent.ON_MOVE | Agent.ON_RESIZE | Agent.ON_TRANSLATE,
				objectMoveHandler,
				object
			);
            
            return this;
        }
		
		
		public function objectMoveHandler(object:Agent, applicable:uint, data:*):void 
		{
			// Tricky: addObject calls can be minimized by using a fill factor threshold
			// rather than re-adding the object to self upon moving.
			var fillFactor:Number = Math.max(object.width / rect.width, object.height / rect.height);
			
			
			// Optimization: If object straddles half-way of any axis, do not re-add if fill factor is < 1.
			var halfwayStraddler:Boolean = (object.left / object.width - 0.5) * (object.right / object.width - 0.5) < 0;
			halfwayStraddler = halfwayStraddler || (object.top / object.height - 0.5) * (object.bottom / object.height - 0.5) < 0;
			
			
			if ( (!halfwayStraddler && fillFactor < 0.25) || !rect.containsRect(object) )
			{
				//Object is no longer well contained by self
				deleteObject(object);
				root.addObject(object);
			}
		}
        
        
        public function queryVolume( query:Rectangle, group:uint, collisions:Vector.<Agent> ) : void {
			
			//Precalculate half width and half height for efficiency.
			var halfWidth  : Number = rect.width / 2,
				halfHeight : Number = rect.height / 2,
				X : Number = rect.x,
				Y : Number = rect.y;
				
            var quad       : uint, object : uint, 
                quadRect   : Rectangle = new Rectangle(X, Y, halfWidth, halfHeight);
			
            //Collect all object IDs intersected by the query
            for( object = 0; object < objects.length; object++ ) {
                if( (group & objects[object].group) == 0)
                    continue;
                
                else if( query.intersects(objects[object]) )
                    collisions.push(objects[object]);

            }
            
            //Descend into all quadrants intersected by the query
            for( var qy : uint = 0; qy < 2; qy++ ) {
                for( var qx : uint = 0; qx < 2; qx++ ) {
                    quadRect.x = X + qx * halfWidth;
					quadRect.y = Y + qy * halfHeight;

                    if( children[quad] != null && rect.intersects(quadRect) )
                        children[quad].queryVolume(query, group, collisions);
                    
                    quad++;
                }
            }
        }
        
        
        public function queryPoint( point:Point, group:uint, collisions:Vector.<Agent> ) : void {
			
			//Precalculate half width and half height for efficiency.
			var halfWidth  : Number = rect.width / 2,
				halfHeight : Number = rect.height / 2,
				X : Number = rect.x,
				Y : Number = rect.y;
				
            var quad       : uint,
                quadRect   : Rectangle = new Rectangle(X, Y, halfWidth, halfHeight);
            
            //Collect all object IDs intersected by the query
            for( var object : uint = 0; object < objects.length; object++ ) {
                if( (group & objects[object].group) == 0 )
                    continue;
                
                else if( (objects[object] as Rectangle).containsPoint(point) )
                    collisions.push(objects[object]);
            }
            
            //Descend into all quadrants intersected by the query
            for( var qy : uint = 0; qy < 2; qy++ ) {
                for( var qx : uint = 0; qx < 2; qx++ ) {
                    quadRect.x = X + qx * halfWidth;
					quadRect.y = Y + qy * halfHeight;
                    
                    if( children[quad] != null && quadRect.containsPoint(point) ) {
                        children[quad].queryPoint(point, group, collisions);
                    }
                    
                    quad++;
                }
            }
        }

        
        public function queryCollisions( collisions:Vector.<Collision> ) : void {
            //Test all objects at this node against each other
			var a:Agent, b:Agent;
			var i:uint, j:uint;
			var objectCount:uint = objects.length;
			
			collisionChecks = 0;
			
            for( i = 0; i < objectCount-1; i++ ) {
                for ( j = i + 1; j < objectCount; j++ ) {
					
					collisionChecks++;
					
					a = objects[i];
					b = objects[j];
					
                    if( (a.action & b.group | a.group & b.action) == 0 )
                        continue;
                    
                    else if( a.intersects(b) )
                        collisions.push(
                            new Collision(a, b)
                        );
                }
            }
            
            //Test all objects at this node against all ancestor objects
            var ancestor : TreeNode = parent;
			var ancestorObjectCount:uint;
            
            while ( ancestor != null ) {
				ancestorObjectCount = ancestor.objects.length;
				
                for( i = 0; i < objectCount; i++ ) {
                    for ( j = 0; j < ancestorObjectCount; j++ ) {
						
						a = objects[i];
						b = ancestor.objects[j];
						
						if( (a.action & b.group | a.group & b.action) == 0 )
							continue;
                        
                        else if( a.intersects(b) )
                            collisions.push(
                                new Collision(a, b)
                            );
                    }
                }

                ancestor = ancestor.parent;
            }
            
            //Descend into all active children
            for( i = 0; i < 4; i++ ) {
                if( children[i] != null )
                    children[i].queryCollisions(collisions);
            }
        }
        
        
        public function deleteObject( object:Agent ) : void {
            for( var i : uint = 0; i < objects.length; i++ ) {
                if( objects[i].id == object.id ) {
                    objects[i].onChange.removeListener(Notification.ALL, objectMoveHandler);
                    objects.splice(i, 1);
                    return;
                }
            }
        }
        
        
        public function deleteChild( child:TreeNode ) : void {
            var activeChildren : uint = 0,
                childIndex     : int = -1;
            
            for( var quad : uint = 0; quad < 4; quad++ ) {
                if( children[quad] === child ) {
                    childIndex = quad;
                } else if( children[quad] != null ) {
                    activeChildren++;
                }
            }
            
            if( childIndex == -1 )
                throw new InternalError("Attempted to delete an non-existent child");
            
            TreeNodePool.addObject(children[childIndex]);
            
            children[childIndex] = null;
            
            if( activeChildren == 0 && objects.length == 0 )
                parent.deleteChild(this);
        }
        
    }
    
}