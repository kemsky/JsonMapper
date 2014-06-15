package converter.rest
{
    public class JsonError extends Error
    {
        public function JsonError(message:String = "",id:Number = 0)
        {
            super(message, id);
        }
    }
}
