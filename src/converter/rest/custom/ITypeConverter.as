package converter.rest.custom
{
    /**
     * Converter interface for types(like Date) that are not standard in JSON.
     */
    public interface ITypeConverter
    {
        /**
         * Converts raw value to appropriate object.
         * @param value native JSON output (string or number)
         * @return converted object.
         */
        function fromString(value:*):*;

        function toString(value:*):*;
    }
}
