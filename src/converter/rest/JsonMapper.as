package converter.rest
{
    import avmplus.R;
    import avmplus.Types;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    import mx.collections.ArrayCollection;
    import mx.logging.ILogger;
    import mx.logging.Log;

    /**
     * Creates and stores class descriptors
     */
    public class JsonMapper
    {
        private static const log:ILogger = Log.getLogger("converter.rest.JsonMapper");

        public static const simpleTypeNames:Dictionary = new Dictionary();
        {
            simpleTypeNames["int"] = int;
            simpleTypeNames["Number"] = Number;
            simpleTypeNames["uint"] = uint;
            simpleTypeNames["String"] = String;
            simpleTypeNames["Boolean"] = Boolean;
            simpleTypeNames["Array"] = Array;
            simpleTypeNames["Date"] = Date;
            simpleTypeNames["Object"] = Object;
        }

        public static const simpleTypes:Dictionary = new Dictionary();
        {
            simpleTypes[int] = "int";
            simpleTypes[Number] = "Number";
            simpleTypes[uint] = "uint";
            simpleTypes[String] = "String";
            simpleTypes[Boolean] = "Boolean";
            simpleTypes[Array] = "Array";
            simpleTypes[Date] = "Date";
            simpleTypes[Object] = "Object";
            simpleTypes[ArrayCollection] = "mx.collections::ArrayCollection";
        }

        /**
         * Property annotation name
         */
        private static const JSON_METADATA:String = "Serialized";

        /**
         * Array property annotation name
         */
        private static const ARRAY_ELEMENT_TYPE_METADATA:String = "ArrayElementType";

        /**
         * Store for created JsonDescriptors
         * @see converter.rest.JsonObject
         */
        private const registry:Dictionary = new Dictionary();

        /**
         * Create and store class descriptor
         * @param type class
         */
        public function registerClass(type:Class):void
        {
            if (type == null || registry[type] != null || simpleTypes[type] != null || isVector(Types.getQualifiedClassName(type)))
            {
                //no need to parse this type
                return;
            }

            var start:Number = getTimer();

            var descriptor:Object = R.describe(type,  R.ACCESSORS | R.VARIABLES | R.METADATA | R.TRAITS);

            [ArrayElementType("converter.rest.JsonObjectProperty")]
            var properties:Array = [];

            var propertiesMap:Dictionary = new Dictionary();

            this.registry[type] = new JsonObject(type, properties, propertiesMap);

            parseProperties(descriptor.traits.accessors, propertiesMap, properties, descriptor.name);
            parseProperties(descriptor.traits.variables, propertiesMap, properties, descriptor.name);

            log.info("registered {0}, {1} ms", descriptor.name, getTimer() - start);
        }

        /**
         * Get class descriptor by class
         * @param type class
         * @return class descriptor
         * @see converter.rest.JsonObject
         */
        public function getClass(type:Class):JsonObject
        {
            var descriptor:JsonObject = registry[type];

            if(descriptor == null)
            {
                if(simpleTypes[type] != null)
                {
                    descriptor = new JsonObject(type, [], new Dictionary());
                }
            }

            if (descriptor == null)
            {
                throw new JsonError("Type was not registered: " + Types.getQualifiedClassName(type));
            }

            return  descriptor;
        }

        private function parseProperties(props:Array, propertiesMap:Dictionary, properties:Array, className:String):void
        {
            var propertyDescriptor:JsonObjectProperty;
            var property:Object;
            var serialized:Object;

            for each (property in props)
            {
                serialized = getMetadata(JSON_METADATA, property);
                if (serialized)
                {
                    if(property.access == "readwrite")
                    {
                        propertyDescriptor = parseProperty(property, serialized);
                        propertiesMap[propertyDescriptor.name] = propertyDescriptor;
                        properties.push(propertyDescriptor);
                    }
                    else
                    {
                        throw new JsonError("Property is not writable: " + className + "." + property.name);
                    }
                }
            }
        }

        private function parseProperty(property:Object, serialized:Object):JsonObjectProperty
        {
            var propertyDescriptor:JsonObjectProperty = new JsonObjectProperty();

            var typeName:String = property.type;

            var collection:Object = getMetadata(ARRAY_ELEMENT_TYPE_METADATA, property);

            propertyDescriptor.name = property.name;
            propertyDescriptor.typeName = typeName;
            propertyDescriptor.type = simpleTypeNames[typeName];


            if(serialized.value.length == 1 && serialized.value[0].key == "required")
            {
                propertyDescriptor.isRequired = serialized.value[0].value == "true";
            }

            if (propertyDescriptor.type == null)
            {
                propertyDescriptor.type = Types.getDefinitionByName(typeName);
                registerClass(propertyDescriptor.type);
            }
            else
            {
                propertyDescriptor.isSimple = true;
                propertyDescriptor.isNumber = isNumber(propertyDescriptor.type);
            }

            propertyDescriptor.isDate = propertyDescriptor.type == Date;

            if (collection)
            {
                propertyDescriptor.isCollection = true;

                propertyDescriptor.isArray = propertyDescriptor.type == Array;
                propertyDescriptor.isVector = isVector(propertyDescriptor.typeName);

                var elementType:String = collection.value.length == 1 ? collection.value[0].value : null;
                propertyDescriptor.elementType = simpleTypeNames[elementType];
                propertyDescriptor.elementTypeName = elementType;
                if (propertyDescriptor.elementType == null)
                {
                    propertyDescriptor.elementType = Types.getDefinitionByName(elementType);
                    registerClass(propertyDescriptor.elementType);
                }
                else
                {
                    propertyDescriptor.isElementSimple = true;
                    propertyDescriptor.isElementNumber = isNumber(propertyDescriptor.elementType);
                }

                propertyDescriptor.isElementDate = propertyDescriptor.elementType == Date;
            }
            else if(propertyDescriptor.type == Array || isVector(propertyDescriptor.typeName) ||
                    propertyDescriptor.type == ArrayCollection)
            {
                throw new JsonError("Collection must be marked with ArrayElementType metadata, " + propertyDescriptor + "." + propertyDescriptor.name);
            }

            return propertyDescriptor;
        }

        private function getMetadata(name:String, property:Object):Object
        {
            for each (var metadata:Object in property.metadata)
            {
                if(metadata.name == name)
                {
                    return metadata;
                }
            }
            return null;
        }

        internal function isNumber(clazz:Class):Boolean
        {
            return clazz == Number || clazz == int || clazz == uint;
        }

        internal function isVector(classType:String):Boolean
        {
            return classType.indexOf("__AS3__.vec::Vector") == 0;
        }
    }
}
