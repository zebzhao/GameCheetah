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