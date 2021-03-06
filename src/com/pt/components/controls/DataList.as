package com.pt.components.controls
{
    import com.pt.components.containers.layout.ComponentLayout;
    import com.pt.components.containers.layout.ListLayout;
    import com.pt.virtual.Dimension;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.core.IDataRenderer;
    import mx.core.IFactory;
    import mx.core.IInvalidating;
    import mx.core.IUIComponent;
    import mx.core.UIComponent;
    import mx.styles.ISimpleStyleClient;
    
    [Style(name="itemRendererStyleName", type="String")]
    
    public class DataList extends UIComponent
    {
        private var layout:ComponentLayout;
        
        public function DataList()
        {
            super();
            layout = new ListLayout();
            layout.target = this;
        }
        
        private var _itemSize:Number = NaN;
        
        public function get itemSize():Number
        {
            return _itemSize;
        }
        
        public function set itemSize(value:Number):void
        {
            if(value === _itemSize)
                return;
            
            _itemSize = value;
            if(isNaN(value))
                variableItemSize = true;
        }
        
        private var _variableItemSize:Boolean = true;
        
        public function get variableItemSize():Boolean
        {
            return _variableItemSize;
        }
        
        public function set variableItemSize(value:Boolean):void
        {
            if(_variableItemSize === value)
                return;
            
            _variableItemSize = value;
            
            if(variableItemSize == false && isNaN(itemSize))
                _itemSize = 25;
            
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
        }
        
        private var _horizontalScrollPosition:Number = -1;
        
        public function get horizontalScrollPosition():Number
        {
            return _horizontalScrollPosition;
        }
        
        public function set horizontalScrollPosition(value:Number):void
        {
            if(value === _horizontalScrollPosition)
                return;
            
            newRendererInView.x = int((value < _horizontalScrollPosition) ?
                value <= scrollDelta[1].x :
                value + width >= scrollDelta[1].y);
            
            _horizontalScrollPosition = value;
            
            setScrollRect();
            
            if(newRendererInView.x)
            {
                lastRendererScrollPosition.x = value;
                invalidateProperties();
            }
            
            invalidateDisplayList();
        }
        
        private var _verticalScrollPosition:Number = -1;
        
        public function get verticalScrollPosition():Number
        {
            return _verticalScrollPosition;
        }
        
        public function set verticalScrollPosition(value:Number):void
        {
            if(value === _verticalScrollPosition)
                return;
            
            newRendererInView.y = int((value < _verticalScrollPosition) ?
                value <= scrollDelta[0].x :
                value + height >= scrollDelta[0].y);
            
            _verticalScrollPosition = value;
            
            setScrollRect();
            
            if(newRendererInView.y)
            {
                lastRendererScrollPosition.y = value;
                invalidateProperties();
            }
            
            invalidateDisplayList();
        }
        
        protected var dataProviderChanged:Boolean = false;
        
        private var _dataProvider:Object;
        
        public function get dataProvider():Object
        {
            return _dataProvider;
        }
        
        public function set dataProvider(value:Object):void
        {
            if(value === _dataProvider)
                return;
            
            _dataProvider = value;
            dataProviderChanged = true;
            
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
        }
        
        protected var itemRendererChanged:Boolean = false;
        protected var itemRendererFactory:IFactory;
        
        protected var renderers:Array;
        
        public function set itemRenderer(factory:IFactory):void
        {
            if(factory == itemRendererFactory)
                return;
            
            itemRendererFactory = factory;
            itemRendererChanged = true;
            
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
        }
        
        public function sort(sortFunc:Function, ...sortOptions):void
        {
        }
        
        protected var _dimension:Dimension;
        
        public function get dimension():Dimension
        {
          return _dimension;
        }
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            renderers = [];
            
            if(!_dimension)
              _dimension = new Dimension();
        }
        
        protected function commitRendererData():void
        {
            if(!processRendererData() || !scrollRect)
                return;
            
            var minPosition:Number = scrollRect.y;
            var maxPosition:Number = minPosition + scrollRect.height;
            
            var d:Dimension = dimension;
            var items:Array = d.getBetween(minPosition, maxPosition);
            var n:int = items.length;
            var renderer:DisplayObject;
            
            for(var i:int = 0; i < n; i++)
            {
                if(i in renderers)
                    renderer = renderers[i];
                else
                {
                    renderers.push(renderer = itemRendererFactory.newInstance());
                    if(renderer is ISimpleStyleClient)
                        ISimpleStyleClient(renderer).styleName = getStyle("itemRendererStyleName");
                    addChild(renderer as DisplayObject);
                }
                
                setRendererData(renderer, items[i], d.getIndex(items[i]));
            }
            
            while(renderers.length > n)
            {
                removeChild(renderers.splice(renderers.length - 1, 1)[0]);
            }
        }
        
        protected function processRendererData():Boolean
        {
            var newRenderer:Boolean = Boolean(newRendererInView.y);
            return (dataProviderChanged || itemRendererChanged || newRenderer);
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if(dataProviderChanged || (dataProvider && itemRendererChanged))
            {
                // Only do this when the data or itemRenderer changes. This is an incredibly
                // intensive operation, so change the data/renderers as little as possible.
                measureAllDataItems();
            }
            
            if(processRendererData())
            {
                commitRendererData();
            }
        }
        
        override protected function measure():void
        {
            if(dataProviderChanged || (dataProvider && itemRendererChanged))
            {
                layout.measure();
            }
        }
        
        protected var scrollDelta:Vector.<Point> = new <Point>[new Point(), new Point()];
        protected var lastRendererScrollPosition:Point = new Point(-10000, -10000);
        protected var newRendererInView:Point = new Point();
        
        protected function setRendererData(renderer:DisplayObject, data:Object, index:int):void
        {
            if(!('data' in renderer))
                return;
            
            renderer['data'] = data;
        }
        
        protected function setScrollRect():void
        {
            scrollRect = new Rectangle(horizontalScrollPosition, verticalScrollPosition, unscaledWidth, unscaledHeight);
        }
        
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            setScrollRect();
            
            layout.updateDisplayList(w, h);
            
            if(renderers.length > 0)
            {
                var item:Object = renderers[0]['data'];
                var scrollIndex:int = 0;
                scrollDelta[scrollIndex].x = dimension.getPosition(item);
                item = renderers[renderers.length - 1]['data'];
                scrollDelta[scrollIndex].y = dimension.getPosition(item) + dimension.getSize(item);
            }
            
            newRendererInView.x = 0;
            newRendererInView.y = 0;
            itemRendererChanged = false;
            dataProviderChanged = false;
        }
        
        protected function measureAllDataItems():void
        {
            if(!itemRendererFactory)
                return;
            
            dimension.clear();
            
            measuredWidth = 0;
            measuredHeight = 0;
            
            var renderer:DisplayObject = itemRendererFactory.newInstance();
            
            if(renderer is ISimpleStyleClient)
                ISimpleStyleClient(renderer).styleName = getStyle("itemRendererStyleName");
            
            addChild(renderer);
            
            // Assume data is an Array, TODO: Update this to work with any collection.
            var a:Array = dataProvider as Array;
            var i:int = 0;
            var n:int = a.length;
            var rSize:Point = new Point();
            
            // measure all the rows
            if(variableItemSize)
            {
                for(i = 0; i < n; i++)
                {
                    setRendererData(renderer, a[i], i);
                    
                    if(renderer is IInvalidating)
                        IInvalidating(renderer).validateNow();
                    
                    rSize = getRendererSize(renderer);
                    
                    enqueueDataItem(renderer, a[i]);
                    measuredWidth = Math.max(rSize.x, measuredWidth);
                    measuredHeight = measuredHeight + rSize.y;
                }
            }
            else
            {
                setRendererData(renderer, a[0], 0);
                
                renderer.height = itemSize;
                
                if(renderer is IInvalidating)
                    IInvalidating(renderer).validateNow();
                
                rSize = getRendererSize(renderer);
                measuredWidth = Math.max(rSize.x, measuredWidth);
                measuredHeight = Math.max(itemSize, 0) * n;
                for(i = 0; i < n; i++)
                {
                    enqueueDataItem(renderer, a[i]);
                }
            }
            
            if(renderer is ISimpleStyleClient)
                ISimpleStyleClient(renderer).styleName = null;
            
            if(renderer is IDataRenderer)
                IDataRenderer(renderer).data = null;
            
            removeChild(renderer);
            
            renderer = null;
        }
        
        protected function getRendererSize(renderer:DisplayObject):Point
        {
            var p:Point = new Point();
            if(renderer is IUIComponent)
            {
                p.x = IUIComponent(renderer).getExplicitOrMeasuredWidth();
                p.y = IUIComponent(renderer).getExplicitOrMeasuredHeight();
            }
            else
            {
                p.x = renderer.width;
                p.y = renderer.height;
            }
            return p;
        }
        
        protected function enqueueDataItem(renderer:DisplayObject, data:Object):void
        {
            var num:Number = renderer is IUIComponent ?
                IUIComponent(renderer).getExplicitOrMeasuredHeight() :
                renderer.height;
            
            dimension.add(data, num);
        }
    }
}