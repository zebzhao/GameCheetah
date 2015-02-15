package gamecheetah.strix.collision.quadtree {

	import gamecheetah.strix.collision.Agent;
	import gamecheetah.strix.collision.Collision;
	import gamecheetah.strix.collision.error.IllegalBoundsError;
	import gamecheetah.strix.collision.error.InvalidObjectError;
	import gamecheetah.strix.hashtable.Hashtable;
	import flash.geom.Point;
	import flash.geom.Rectangle;
   
    /**
	 * @private
	 */
    public final class Quadtree {
        
        private var
            rootNode   : TreeNode,
            idTreeNode : Hashtable;
            
        public static var
            throwExceptions : Boolean = true;
        
            
        public function Quadtree( rect:Rectangle, maxDepth:uint=8  ) {
            this.rootNode = new TreeNode(rect, 0, maxDepth-1, null, null);
            this.rootNode.root = this.rootNode;
            this.idTreeNode = new Hashtable(int(Math.pow(2, maxDepth / 2)), CONFIG::developer);
        }
		
		public function print():String 
		{
			return "> Root" + rootNode.print("\t");
		}

        public function addAgent( agent:Agent ) : void {
            if( throwExceptions && idTreeNode[agent.id] != null )
                throw new InvalidObjectError("Object with ID " + agent.id + " already exists.");
            
            if( throwExceptions && !rootNode.rect.containsRect(agent) )
                throw new IllegalBoundsError("Object with ID " + agent.id + " has illegal bounds.");
            
            idTreeNode[agent.id] = rootNode.addObject(agent);
        }
        

        public function deleteAgent( agent:Agent ) : void {
            var treeNode : TreeNode = idTreeNode[agent.id] as TreeNode;
            
            if( throwExceptions && treeNode == null )
                throw new InvalidObjectError("Object with ID " + agent.id + " does not exist.");
            
            treeNode.deleteObject(agent);
            delete idTreeNode[agent.id];
        }

        
        public function queryVolume( rect:Rectangle, group:uint=0xffffffff ) : Vector.<Agent> {
            if( throwExceptions && !rootNode.rect.containsRect(rect) )
                throw new IllegalBoundsError("Region of interest has illegal bounds.");
            
            var objects : Vector.<Agent> = new Vector.<Agent>;
            
            rootNode.queryVolume(rect, group, objects);
            
            if( objects.length > 0 ) {
                return objects;
            }
            
            return null;
        }

        
        public function queryPoint( point:Point, group:uint=0xffffffff ) : Vector.<Agent> {
            if( throwExceptions && !rootNode.rect.containsPoint(point) )
                throw new IllegalBoundsError("Query is out of bounds.");
            
            var agents : Vector.<Agent> = new Vector.<Agent>;
            
            rootNode.queryPoint(point, group, agents);
            
            if( agents.length > 0 ) {
                return agents;
            }
            
            return null;
        }
       

        public function queryCollisions() : Vector.<Collision> {
            var collisions : Vector.<Collision> = new Vector.<Collision>;
            
            rootNode.queryCollisions(collisions);
            
            if( collisions.length > 0 ) {
                return collisions;
            }
            
            return null;
        }
        
    }
    
}