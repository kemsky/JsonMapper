package converter.rest
{
    import converter.rest.vo.JsonArrayCollectionVO;
    import converter.rest.vo.JsonArrayVO;
    import converter.rest.vo.JsonReadOnlyVO;
    import converter.rest.vo.JsonVO;
    import converter.rest.vo.JsonVectorVO;

    import mx.collections.ArrayCollection;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertNotNull;

    public class JsonMapperTest
    {
        [Test]
        public function testMissingArrayType():void
        {
            var mapper:JsonMapper = new JsonMapper();

            try
            {
                mapper.registerClass(JsonArrayVO);
                assertFalse(true);
            }
            catch(e:JsonError)
            {
            }

            try
            {
                mapper.registerClass(JsonArrayCollectionVO);
                assertFalse(true);
            }
            catch(e:JsonError)
            {
            }

            try
            {
                mapper.registerClass(JsonVectorVO);
                assertFalse(true);
            }
            catch(e:JsonError)
            {
            }
        }


        [Test]
        public function testReadOnly():void
        {
            var mapper:JsonMapper = new JsonMapper();

            try
            {
                mapper.registerClass(JsonReadOnlyVO);
                assertFalse(true);
            }
            catch(e:JsonError)
            {
            }
        }

        [Test]
        public function testMapping():void
        {
            var mapper:JsonMapper = new JsonMapper();
            mapper.registerClass(JsonVO);

            var cls:JsonObject = mapper.getClass(JsonVO);

            assertEquals(11, cls.properties.length);


            var property:JsonObjectProperty = cls.propertiesMap["id"];
            assertNotNull(property);
            assertEquals(true, property.isRequired);
            assertEquals(String, property.type);
            assertEquals("String", property.typeName);
            assertEquals(null, property.elementType);
            assertEquals(null, property.elementTypeName);
            assertEquals(false, property.isArray);
            assertEquals(false, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(false, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(true, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("id", property.name);

            property = cls.propertiesMap["path"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(String, property.type);
            assertEquals("String", property.typeName);
            assertEquals(null, property.elementType);
            assertEquals(null, property.elementTypeName);
            assertEquals(false, property.isArray);
            assertEquals(false, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(false, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(true, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("path", property.name);

            property = cls.propertiesMap["name"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(String, property.type);
            assertEquals("String", property.typeName);
            assertEquals(null, property.elementType);
            assertEquals(null, property.elementTypeName);
            assertEquals(false, property.isArray);
            assertEquals(false, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(false, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(true, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("name", property.name);


            property = cls.propertiesMap["description"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(String, property.type);
            assertEquals("String", property.typeName);
            assertEquals(null, property.elementType);
            assertEquals(null, property.elementTypeName);
            assertEquals(false, property.isArray);
            assertEquals(false, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(false, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(true, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("description", property.name);

            property = cls.propertiesMap["value"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(Number, property.type);
            assertEquals("Number", property.typeName);
            assertEquals(null, property.elementType);
            assertEquals(null, property.elementTypeName);
            assertEquals(false, property.isArray);
            assertEquals(false, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(false, property.isElementSimple);
            assertEquals(true, property.isNumber);
            assertEquals(true, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("value", property.name);


            property = cls.propertiesMap["date"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(Date, property.type);
            assertEquals("Date", property.typeName);
            assertEquals(null, property.elementType);
            assertEquals(null, property.elementTypeName);
            assertEquals(false, property.isArray);
            assertEquals(false, property.isCollection);
            assertEquals(true, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(false, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(true, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("date", property.name);


            property = cls.propertiesMap["properties"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(Array, property.type);
            assertEquals("Array", property.typeName);
            assertEquals(JsonVO, property.elementType);
            assertEquals("converter.rest.vo.JsonVO", property.elementTypeName);
            assertEquals(true, property.isArray);
            assertEquals(true, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(false, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(true, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("properties", property.name);


            property = cls.propertiesMap["vector"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(Vector.<String>, property.type);
            assertEquals("__AS3__.vec::Vector.<String>", property.typeName);
            assertEquals(String, property.elementType);
            assertEquals("String", property.elementTypeName);
            assertEquals(false, property.isArray);
            assertEquals(true, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(true, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(false, property.isSimple); //todo make vector simple
            assertEquals(true, property.isVector);
            assertEquals("vector", property.name);


            property = cls.propertiesMap["booleans"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(Array, property.type);
            assertEquals("Array", property.typeName);
            assertEquals(Boolean, property.elementType);
            assertEquals("Boolean", property.elementTypeName);
            assertEquals(true, property.isArray);
            assertEquals(true, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(true, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(true, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("booleans", property.name);


            property = cls.propertiesMap["aCollection"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(ArrayCollection, property.type);
            assertEquals("mx.collections::ArrayCollection", property.typeName);
            assertEquals(int, property.elementType);
            assertEquals("int", property.elementTypeName);
            assertEquals(false, property.isArray);
            assertEquals(true, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(true, property.isElementNumber);
            assertEquals(true, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(false, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("aCollection", property.name);


            property = cls.propertiesMap["nested"];
            assertNotNull(property);
            assertEquals(false, property.isRequired);
            assertEquals(Array, property.type);
            assertEquals("Array", property.typeName);
            assertEquals(JsonVO, property.elementType);
            assertEquals("converter.rest.vo.JsonVO", property.elementTypeName);
            assertEquals(true, property.isArray);
            assertEquals(true, property.isCollection);
            assertEquals(false, property.isDate);
            assertEquals(false, property.isElementDate);
            assertEquals(false, property.isElementNumber);
            assertEquals(false, property.isElementSimple);
            assertEquals(false, property.isNumber);
            assertEquals(true, property.isSimple);
            assertEquals(false, property.isVector);
            assertEquals("nested", property.name);
        }
    }
}
