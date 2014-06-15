package converter.rest
{
    import flash.utils.Dictionary;

    /**
     * Class descriptor
     */
    public class JsonObject
    {
        /**
         * Class
         */
        public var type:Class;

        /**
         * Variables and accessors descriptors
         * @see converter.rest.JsonObjectProperty
         */
        [ArrayElementType("converter.rest.JsonObjectProperty")]
        public var properties:Array;

        /**
         * Variable/accessor name to descriptor map
         * @see converter.rest.JsonObjectProperty
         */
        public var propertiesMap:Dictionary;

        public function JsonObject(type:Class, properties:Array, propertiesMap:Dictionary)
        {
            this.type = type;
            this.properties = properties;
            this.propertiesMap = propertiesMap;
        }
    }
}
