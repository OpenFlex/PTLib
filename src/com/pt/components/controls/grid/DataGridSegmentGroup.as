package com.pt.components.controls.grid
{
    import com.pt.components.controls.grid.itemRenderers.DataGridSegmentRendererBase;
    
    import flash.geom.Point;
    
    import mx.core.ClassFactory;

    public class DataGridSegmentGroup extends DataGridSegment
    {
        public function DataGridSegmentGroup()
        {
            renderer = new ClassFactory(DataGridSegmentRendererBase);
        }
        
        override public function get relativeMinSize():Number
        {
          var kidsSize:Number = 0;
          var n:int = kids.length;
          for(var i:int = 0; i < n; ++i)
          {
              kidsSize += kids[i].relativeMinSize;
          }
          
          return Math.max(kidsSize, minSize);
        }
        
        private var kids:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
        
        public function get children():Vector.<DataGridSegment>
        {
            return kids;
        }
        
        public function set children(value:Vector.<DataGridSegment>):void
        {
            kids.length = 0;
            var n:int = value.length;
            for(var i:int = 0; i < n; i++)
            {
                value[i].parent = this;
                kids.push(value[i]);
            }
        }
        
        override public function set position(value:Point):void
        {
            var changed:Boolean = value === pos;
            super.position = value;
            
            if(!changed)
                return;
            
            for each(var s:DataGridSegment in children)
            {
                s.parent = this;
            }
        }
    }
}