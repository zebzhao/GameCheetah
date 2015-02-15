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
    
	import flash.geom.Rectangle;
    
    /**
	 * @private
	 */
    internal final class TreeNodePool {
        
        private static const
            POOL_SIZE : uint = 32;
            
        private static var
            pool     : Vector.<TreeNode>,
            poolItem : int;
            
            
        {
            pool = new Vector.<TreeNode>(POOL_SIZE, true);
            
            for( poolItem = 0; poolItem < POOL_SIZE; poolItem++ ) {
                pool[poolItem] = new TreeNode(new Rectangle(), 0, 0, null, null);
            }
            
            poolItem = POOL_SIZE - 1;
        }
        
        
        public static function getObject(
            rect:Rectangle,
            depth:uint, maxDepth:uint,
            parent:TreeNode, root:TreeNode ) : TreeNode {
            
            if( poolItem < 0 ) {
                return new TreeNode(
                    rect,
                    depth, maxDepth,
                    parent, root
                );
            }
            
            var treeNode : TreeNode = pool[poolItem];
            
            pool[poolItem--] = null;
            
            treeNode.rect = rect;
            treeNode.depth = depth;
            treeNode.maxDepth = maxDepth;
            treeNode.parent = parent;
            treeNode.root = root;
            
            return treeNode;
        }
        
        
        public static function addObject( treeNode:TreeNode ) : void {
            if( !(poolItem < POOL_SIZE) )
                return;
            
            pool[poolItem++] = treeNode;
        }
        
    }
    
}