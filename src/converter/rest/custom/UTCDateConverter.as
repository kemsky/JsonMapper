package converter.rest.custom
{
    public class UTCDateConverter implements ITypeConverter
    {
        public function fromString(value:*):*
        {
            return DateUtil.parseW3CDTF(value);
        }

        public function toString(value:*):*
        {
            return DateUtil.toW3CDTF(value);
        }
    }
}
