JsonMapper
==========

Typed JSON parser for ActionScript

Uses built-in [JSON](http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/JSON.html) class if available, 
also can fall back to pure ActionScript JSON parser [implementation](https://github.com/mikechambers/as3corelib). 

Usage

1. Mapping example:
    ```ActionScript
    package converter.rest.vo
    {
        import mx.collections.ArrayCollection;
    
        public class JsonVO
        {
            [Serialized(required="true")]
            public var id:String = null;
    
            [Serialized]
            public var path:String = null;
    
            [Serialized(required="false")]
            public var name:String = null;
    
            [Serialized]
            public var description:String = null;
    
            [Serialized]
            public var value:Number;
    
            [Serialized]
            public var date:Date;
    
            [Serialized]
            [ArrayElementType("converter.rest.vo.JsonVO")]
            public var properties:Array;
    
            [Serialized]
            [ArrayElementType("String")]
            public var vector:Vector.<String> = Vector.<String>(["test", "test"]);
    
            [Serialized]
            [ArrayElementType("Boolean")]
            public var booleans:Array = [[true, false], [true, false]];
    
            [Serialized]
            [ArrayElementType("converter.rest.vo.JsonVO")]
            public var nested:Array = [];
    
            [Serialized]
            [ArrayElementType("int")]
            public var aCollection:ArrayCollection = new ArrayCollection([1, 2, 3]);
        }
    }
    ```