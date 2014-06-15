package converter.rest.vo
{
    public class JsonReadOnlyVO
    {
        [Serialized]
        public function get id():int
        {
            return 0;
        }
    }
}
