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

	import flash.utils.Dictionary;
	import gamecheetah.strix.collision.Agent;
	import gamecheetah.strix.collision.Collision;
	import gamecheetah.strix.collision.error.InvalidObjectError;
	import gamecheetah.strix.utils.Statistics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
   
    /**
	 * @private
	 */
    public final class Quadtree {
        
        private var
            rootNode   : TreeNode,
            idTreeNode : Dictionary;
		
		/**
		 * Total number of rough collision checks performed by the quadtree.
		 * Performance metric used to determine how well the quadtree is scaling to spatial distribution of objects.
		 */
		public function get totalCollisionChecks():uint 
		{
			var totalChecks:uint;
			var nodeList:Vector.<TreeNode> = new <TreeNode> [rootNode];
			var node:TreeNode;
			
			while (nodeList.length > 0)
			{
				node = nodeList.pop();
				if (node != null)
				{
					nodeList = nodeList.concat(node.children);
					totalChecks += node.collisionChecks;
				}
			}
			return totalChecks;
		}
		
		/**
		 * Return the max, mean, and std of bin sizes.
		 * These performance metric are used to determine how well the quadtree is scaling to spatial distribution of objects.
		 */
		public function getStats():Array 
		{
			var binCounts:Vector.<int> = new Vector.<int>();
			var nodeList:Vector.<TreeNode> = new <TreeNode> [rootNode];
			var node:TreeNode;
			
			while (nodeList.length > 0)
			{
				node = nodeList.pop();
				if (node != null)
				{
					nodeList = nodeList.concat(node.children);
					binCounts.push(node.objects.length);
				}
			}
			return [Statistics.max(binCounts), Statistics.mean(binCounts), Statistics.std(binCounts)];
		}
            
        public function Quadtree( rect:Rectangle, maxDepth:uint=8  ) {
            this.rootNode = new TreeNode(rect, 0, maxDepth-1, null, null);
            this.rootNode.root = this.rootNode;
            this.idTreeNode = new Dictionary();
        }
		
		public function print():String 
		{
			return "> Root" + rootNode.print("\t");
		}

        public function addAgent( agent:Agent ) : void {
            if( idTreeNode[agent.id] != null )
                return;
            
			agent.node = rootNode.addObject(agent)
            idTreeNode[agent.id] = agent;
        }
        

        public function deleteAgent( agent:Agent ) : void {
            var treeNode : TreeNode = idTreeNode[agent.id].node as TreeNode;
            
            if( treeNode == null )
                throw new InvalidObjectError("Object with ID " + agent.id + " does not exist.");
            
            treeNode.deleteObject(agent);
            delete idTreeNode[agent.id];
        }

        
        public function queryVolume( rect:Rectangle, group:uint=0xffffffff ) : Vector.<Agent> {
            var objects : Vector.<Agent> = new Vector.<Agent>;
            
            rootNode.queryVolume(rect, group, objects);
            
            if( objects.length > 0 ) {
                return objects;
            }
            
            return null;
        }

        
        public function queryPoint( point:Point, group:uint=0xffffffff ) : Vector.<Agent> {
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