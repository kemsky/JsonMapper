package converter.rest
{
    /**
     * Property descriptor
     */
    public class JsonObjectProperty
    {
        /**
         * Property name
         */
        public var name:String;

        /**
         * Property class name
         */
        public var typeName:String;

        /**
         * Property class
         */
        public var type:Class;

        /**
         * Should we decode this property?
         */
        public var isSimple:Boolean;

        /**
         * Property is Number
         * @see Number
         */
        public var isNumber:Boolean;

        /**
         * Property is Date
         * @see Date
         */
        public var isDate:Boolean;

        /**
         * Property is ListCollectionView
         * @see  mx.collections.ListCollectionView
         */
        public var isCollection:Boolean;

        /**
         * Property is Array
         * @see Array
         */
        public var isArray:Boolean;

        /**
         * Property is Vector
         * @see Vector
         */
        public var isVector:Boolean;

        /**
         * Property is marked as Required
         */
        public var isRequired:Boolean;

        /**
         * Property collection element class name
         */
        public var elementTypeName:String;

        /**
         * Property collection element class
         */
        public var elementType:Class;

        /**
         * Should we decode element class?
         */
        public var isElementSimple:Boolean;

        /**
         * Property collection element is Number
         * @see Number
         */
        public var isElementNumber:Boolean;

        /**
         * Property collection element is Date
         * @see Date
         */
        public var isElementDate:Boolean;

        public function toString():String
        {
            return "JsonProperty{name=" + String(name) + ",typeName=" + String(typeName) + ",type=" + String(type) + ",isSimple=" + String(isSimple) + ",isNumber=" + String(isNumber) + ",isDate=" + String(isDate) + ",isCollection=" + String(isCollection) + ",isArray=" + String(isArray) + ",isVector=" + String(isVector) + ",isRequired=" + String(isRequired) + ",elementTypeName=" + String(elementTypeName) + ",elementType=" + String(elementType) + ",isElementSimple=" + String(isElementSimple) + ",isElementNumber=" + String(isElementNumber) + ",isElementDate=" + String(isElementDate) + "}";
        }
    }
}
