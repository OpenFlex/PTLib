package com.pt.components.containers.layout
{
    import flash.display.DisplayObject;
    
    import mx.core.IChildList;
    import mx.core.IUIComponent;

    public class HLayout extends ComponentLayout
    {
        public function HLayout()
        {
            super();
        }
        
        override public function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);
            
            var children:Array = [];
            var n:int = target.numChildren;
            
            for(var i:int = 0; i < n; i++)
            {
                children.push(target.getChildAt(i));
            }
            
            var childList:IChildList = new ArrayChildList(children);
            var gap:Number = target.getStyle("horizontalGap");
            
            var numChildrenWithOwnSpace:int = n;
            var obj:DisplayObject;
            
            for(i = 0; i < n; i++)
            {
                obj = childList.getChildAt(i);
                
                if((obj is IUIComponent) && !IUIComponent(obj).includeInLayout)
                    numChildrenWithOwnSpace--;
            }
            
            // stretch everything as needed including heights
            var excessSpace:Number = Flex.flexChildWidthsProportionally(childList, w - (numChildrenWithOwnSpace - 1) * gap, h);
            
            var paddingLeft:Number = target.getStyle("paddingLeft");
            var paddingTop:Number = target.getStyle("paddingTop");
            var horizontalAlign:Number = getHorizontalAlignValue();
            var verticalAlign:Number = getVerticalAlignValue();
            
            var left:Number = paddingLeft + excessSpace * horizontalAlign;
            var top:Number = 0;
            
            for(i = 0; i < n; i++)
            {
                obj = childList.getChildAt(i);
                top = (h - obj.height) * verticalAlign + paddingTop;
                
                if(obj is IUIComponent)
                {
                    IUIComponent(obj).move(Math.floor(left), Math.floor(top));
                    if(IUIComponent(obj).includeInLayout)
                        left += obj.width + gap;
                }
                else
                {
                    obj.x = Math.floor(left);
                    obj.y = Math.floor(top);
                    left += obj.width + gap;
                }
            }
        }
    }
}