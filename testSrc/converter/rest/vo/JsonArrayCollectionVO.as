package converter.rest.vo
{
    import mx.collections.ArrayCollection;

    public class JsonArrayCollectionVO
    {
        [Serialized]
        public var id:int;

        [Serialized]
        public var collection:ArrayCollection;
    }
}
