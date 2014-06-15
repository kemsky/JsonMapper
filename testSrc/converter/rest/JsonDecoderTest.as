package converter.rest
{
    import converter.rest.vo.JsonVO;

    import flash.utils.getTimer;

    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.utils.ObjectUtil;
    import mx.utils.UIDUtil;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;

    public class JsonDecoderTest
    {
        private static const log:ILogger = Log.getLogger("converter.rest.JsonDecoderTest");

        private static const SIZE:int = 100;
        private static const CHILD_SIZE:int = 2;


        public function JsonDecoderTest()
        {
            //init date toJSON converter
            Date.prototype.toJSON = function(arg:*):*
            {
                return JSON$.dateConverter.toString(this);
            };
        }


        [Test]
        public function testRequired():void
        {
            var mapper:JsonMapper = new JsonMapper();
            mapper.registerClass(JsonVO);

            var message:String = JSON$.stringify({});

            try
            {
                new JsonDecoder(mapper).decode(message, JsonVO);
                assertFalse(true);
            }
            catch(e:JsonError)
            {
               assertEquals("Property is required: [class JsonVO] property 'id' [class String]", e.message);
            }
        }

        [Test]
        public function testSimple():void
        {
            var mapper:JsonMapper = new JsonMapper();
            mapper.registerClass(JsonVO);

            var jsonVO:JsonVO = createVO();
            jsonVO.date =  new Date(2013, 12, 20, 0, 0, 0, 0);

            var message:String = JSON$.stringify(jsonVO);

            var start:Number = getTimer();
            var result:JsonVO = new JsonDecoder(mapper).decode(message, JsonVO);
            log.info("converter: {0}ms", getTimer() - start);

            assertEquals(0, ObjectUtil.compare(jsonVO, result));
        }

        [Test]
        public function testArray():void
        {
            var mapper:JsonMapper = new JsonMapper();
            mapper.registerClass(JsonVO);

            log.info("test {0} property objects", SIZE * CHILD_SIZE);

            var properties:Array = [];

            for(var i:int = 0; i < SIZE; i++)
            {
                properties.push(createVO(true, 1));
            }

            var message:String = JSON$.stringify(properties);

            var start:Number = getTimer();
            var result:Array = new JsonDecoder(mapper).decode(message, Array, JsonVO);
            log.info("converter: {0}ms", getTimer() - start);

            assertEquals(ObjectUtil.compare(properties, result), 0);
        }

        [Test]
        public function testSimpleArray():void
        {
            var mapper:JsonMapper = new JsonMapper();
            mapper.registerClass(JsonVO);

            log.info("test {0} objects", SIZE);

            var properties:Array = [];

            for(var i:int = 0; i < SIZE; i++)
            {
                properties.push((Math.random() * 10) | 0);
            }

            var message:String = JSON$.stringify(properties);

            var start:Number = getTimer();
            var result:Array = new JsonDecoder(mapper).decode(message, Array, int);
            log.info("converter: {0}ms", getTimer() - start);

            assertEquals(ObjectUtil.compare(properties, result), 0);
        }

        private function createVO(createChildren:Boolean = true, level:int = 0):JsonVO
        {
            var property:JsonVO = new JsonVO();
            property.date =  new Date(2013, 12, 20, 0, 0, 0, 0);
            property.name = "test" + level;
            property.value = 111;
            property.description = "test" + level;
            property.properties = [];
            property.id = UIDUtil.createUID();

            var vo1:JsonVO = new JsonVO();
            vo1.date =  new Date(2013, 12, 20, 0, 0, 1, 0);
            var vo2:JsonVO = new JsonVO();
            vo1.date =  new Date(2013, 12, 20, 0, 0, 2, 0);
            property.nested.push([vo1, vo2]);

            if(createChildren)
            {
                for(var i:int = 0; i < CHILD_SIZE; i++)
                {
                    property.properties.push(createVO(false, level + 1));
                }
            }

            return property;
        }
    }
}
