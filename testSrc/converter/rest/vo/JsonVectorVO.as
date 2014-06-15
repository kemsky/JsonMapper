package converter.rest.vo
{
    public class JsonVectorVO
    {
        [Serialized]
        public var id:int;

        [Serialized]
        public var collection:Vector.<Object>;
    }
}
