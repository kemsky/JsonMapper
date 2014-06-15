package converter.rest
{
    import avmplus.Types;

    import flash.utils.getTimer;

    import mx.collections.ListCollectionView;
    import mx.logging.ILogger;
    import mx.logging.Log;

    /**
     * Fast and typed JSON parser, based on native JSON parser.
     * Vectors, Arrays(can be nested) and Collections are supported.
     * Fields must be marked with Serialized and ArrayElementType annotations.
     * use -keep-as3-metadata+=Serialized
     */
    public class JsonDecoder
    {
        private static const log:ILogger = Log.getLogger("converter.rest.JsonDecoder");

        private var mapper:JsonMapper;

        /**
         * Creates JSON parser instance.
         * @param mapper mapper used to resolve type descriptors, uses static JsonMapper.instance by default.
         * @see converter.rest.JsonMapper
         */
        public function JsonDecoder(mapper:JsonMapper)
        {
            this.mapper = mapper;
        }

        /**
         * Decodes object from raw JSON message to typed AS3 object.
         * @param message JSON string
         * @param resultClass root object class.
         * @param resultElementClass collection item class (if root object is collection).
         * @return decoded object.
         */
        public function decode(message:String, resultClass:Class, resultElementClass:Class = null):*
        {
            var start:Number = getTimer();

            var raw:Object = JSON$.parse(message);

            log.info("raw objects decoded in {0}ms", getTimer() - start);

            if (resultClass == null)
            {
                throw new JsonError("Descriptor is null!");
            }

            if(resultElementClass == null && resultClass == Object)
            {
                resultElementClass = Object;
            }


            if(resultElementClass == null)
            {
                return parse(raw,  mapper.getClass(resultClass), new resultClass());
            }
            else
            {
                var property:JsonObjectProperty = new JsonObjectProperty();

                property.type = resultClass;
                property.typeName = Types.getQualifiedClassName(resultClass);
                property.elementType = resultElementClass;
                property.elementTypeName = Types.getQualifiedClassName(resultElementClass);
                property.isArray = resultClass == Array;
                property.isVector = mapper.isVector(property.typeName);
                property.isCollection = true;
                property.isElementDate = resultElementClass == Date;
                property.isElementNumber = mapper.isNumber(resultElementClass);
                property.isElementSimple = JsonMapper.simpleTypes[resultElementClass] != null;

                return parse(raw, mapper.getClass(resultElementClass), new resultClass(), property);
            }
        }

        /**
         * @Private
         **/
        private function parse(raw:Object, descriptor:JsonObject, result:*, collection:JsonObjectProperty = null):*
        {
            var value:*;
            var name:String;

            if (collection == null)
            {
                for each (var property:JsonObjectProperty in descriptor.properties)
                {
                    if(property.isRequired)
                    {
                        if(!raw.hasOwnProperty(property.name))
                        {
                            throw new JsonError("Property is required: " + descriptor.type  + " property '" + property.name + "' " + property.type);
                        }
                    }

                    value = raw[property.name];

                    if(property.isDate)
                    {
                        if(value != null && !(value is String))
                        {
                            throw new JsonError("Property type is incorrect: " + descriptor.type + " property '" + property.name + "' expected " + String + ", but got [class " + Types.getQualifiedClassName(value) + "]");
                        }
                    }
                    else if(property.isSimple)
                    {
                        if(value != null && !(value is property.type))
                        {
                            throw new JsonError("Property type is incorrect: " + descriptor.type + " property '" + property.name + "' expected " + property.type + ", but got [class " + Types.getQualifiedClassName(value) + "]");
                        }
                    }
                    else
                    {
                        if(value != null && !(value is Object))
                        {
                            throw new JsonError("Property type is incorrect: " + descriptor.type + " property '" + property.name + "' expected " + property.type + ", but got [class " + Types.getQualifiedClassName(value) + "]");
                        }
                    }

                    if (property.isCollection)
                    {
                        result[property.name] = value == null ? null : parse(value, property.isElementSimple ? null : mapper.getClass(property.elementType), new property.type(), property);
                    }
                    else if (property.isDate)
                    {
                        result[property.name] = value != null ? JSON$.dateConverter.fromString(value) : null;
                    }
                    else if (property.isNumber)
                    {
                        result[property.name] = value == null ? NaN : value;
                    }
                    else if (property.isSimple)
                    {
                        result[property.name] = value;
                    }
                    else
                    {
                        result[property.name] = value == null ? null : parse(value, mapper.getClass(property.type), new property.type());
                    }
                }
            }
            else if (collection.isElementSimple)
            {
                for (name in raw)
                {
                    value = raw[name];

                    //only arrays can be nested
                    if (value is Array)
                    {
                        if (!collection.isArray)
                        {
                            throw  new JsonError("Nested arrays are the only allowed type, but got: [class " + Types.getQualifiedClassName(value) + "]");
                        }
                        else
                        {
                            result.push(parse(value, collection.isElementSimple ? null : mapper.getClass(collection.elementType), new collection.type(), collection));
                            continue;
                        }
                    }

                    if (collection.isElementDate)
                    {
                        value = value != null ? JSON$.dateConverter.fromString(value) : null;
                    }
                    else if (collection.isElementNumber)
                    {
                        value = value == null ? NaN : value;
                    }

                    if (collection.isArray || collection.isVector)
                    {
                        result.push(value);
                    }
                    else if (result is ListCollectionView)
                    {
                        result.addItem(value);
                    }
                    else
                    {
                        result[name] = value;
                    }
                }
            }
            else
            {
                for (name in raw)
                {
                    value = raw[name];

                    //only arrays can be nested
                    if (value is Array)
                    {
                        if (!collection.isArray)
                        {
                            throw  new JsonError("Nested arrays are the only allowed type, but got: [class " + Types.getQualifiedClassName(value) + "]");
                        }
                        else
                        {
                            result.push(parse(value, collection.isElementSimple ? null : mapper.getClass(collection.elementType), new collection.type(), collection));
                            continue;
                        }
                    }

                    value = value == null ? null : parse(value, descriptor, new descriptor.type());

                    if (collection.isArray || collection.isVector)
                    {
                        result.push(value);
                    }
                    else if (result is ListCollectionView)
                    {
                        result.addItem(value);
                    }
                    else
                    {
                        result[name] = value;
                    }
                }
            }
            return result;
        }
    }
}
