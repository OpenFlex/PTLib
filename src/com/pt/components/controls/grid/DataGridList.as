package com.pt.components.controls.grid
{
    import com.pt.components.controls.DataList;
    import com.pt.components.controls.grid.itemRenderers.DataGridListItemRenderer;
    import com.pt.components.controls.grid.itemRenderers.DataGridSegmentRendererBase;
    
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.geom.Point;
    
    import mx.core.ClassFactory;
    
    public class DataGridList extends DataList
    {
        public function DataGridList()
        {
            variableItemSize = false;
            itemRenderer = new ClassFactory(DataGridListItemRenderer);
        }
        
        protected var _segments:Vector.<DataGridSegment> = new Vector.<DataGridSegment>();
        private var segmentsChanged:Boolean = false;
        
        public function get segments():Vector.<DataGridSegment>
        {
            return _segments;
        }
        
        public function set segments(value:Vector.<DataGridSegment>):void
        {
            if(value === _segments)
                return;
            
            _segments = value;
            segmentsChanged = true;
            
            commitRendererData();
            
            invalidateSize();
            invalidateDisplayList();
        }
        
        override protected function processRendererData():Boolean
        {
            return super.processRendererData() || segmentsChanged;
        }
        
        override protected function setRendererData(renderer:DisplayObject, data:Object, index:int):void
        {
            if(renderer is DataGridSegmentRendererBase)
            {
                DataGridSegmentRendererBase(renderer).segments = segments;
                
                if(renderer is DataGridListItemRenderer)
                    DataGridListItemRenderer(renderer).index = index;
            }
            
            super.setRendererData(renderer, data, index);
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            segmentsChanged = false;
            
            super.updateDisplayList(w, h);
        }
    }
}