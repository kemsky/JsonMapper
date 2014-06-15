package converter.rest
{
    import mx.collections.ArrayCollection;
    import mx.logging.ILogger;
    import mx.logging.Log;

    import org.flexunit.asserts.assertEquals;

    public class CollectionJSONTest
    {
        private static const log:ILogger = Log.getLogger("converter.rest.CollectionJSONTest");

        public function CollectionJSONTest()
        {
        }

        //Apache Flex 4.12 only
        //see https://issues.apache.org/jira/browse/FLEX-34108
        [Test]
        public function testEncode():void
        {
            var array:Array = [1, 2, 3];
            var arrayCollection:ArrayCollection = new ArrayCollection(array);
            var jsonArrayCollection:String = JSON$.stringify(arrayCollection);
            var jsonArray:String = JSON$.stringify(array);
            assertEquals(jsonArray, jsonArrayCollection);
        }
    }
}
