package converter.rest
{
    import mx.collections.ArrayCollection;

    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.flexunit.asserts.assertEquals;

    public class JsonCollectionTest
    {
        private static const log:ILogger = Log.getLogger("converter.rest.JsonDecoderTest");

        public function JsonCollectionTest()
        {
        }

        [Test]
        public function testArrayCollection():void
        {
            var base:Array = [1, 2, 3];
            var baseObj:Object = {base:base};

            var aCollection:ArrayCollection = new ArrayCollection(base);

            var result:String = JSON$.stringify(baseObj);

            var aResult:String = JSON$.stringify({base:aCollection});

            log.info("array: {0}", result);
            log.info("ArrayCollection: {0}", aResult);

            assertEquals(result, aResult);
        }
    }
}
