package
{
    import avmplus.Types;

    import converter.rest.JsonError;
    import converter.rest.custom.ITypeConverter;
    import converter.rest.custom.UTCDateConverter;
    import mx.logging.ILogger;
    import mx.logging.Log;

    /**
     * Linux fix, JSON class is missing in Adobe Air 2.6
     */
    public class JSON$
    {
        private static const log:ILogger = Log.getLogger("JSON");

        /**
         * JSON date type converter, default is W3C date converter
         */
        public static var dateConverter:ITypeConverter = new UTCDateConverter();

        /**
         * Use slow as3 serialization, Adobe Air 2.6 compatibility
         * @see https://github.com/mikechambers/as3corelib
         */
        public static var useLegacy:Boolean = false;

        private static var decode:Function;
        private static var encode:Function;

        public static function parse(message:String):*
        {
            if (decode == null)
            {
                if (useLegacy)
                {
                    log.warn("Using JSON decoder workaround for AIR 2.6 [linux]");
                    decode = function (message:String):*
                    {
                        var decoder:Decoder = new Decoder(message, true);
                        return decoder.getValue();
                    };
                }
                else
                {
                    log.info("Using native JSON decoder");
                    var json:Class = Types.getDefinitionByName("JSON") as Class;
                    decode = json["parse"];
                }
            }

            var result:*;

            try
            {
                result = decode.call(null, message);
            }
            catch(e:SyntaxError)
            {
                if(e.errorID == 1132)
                {
                    //rethrow with message
                    throw new JsonError("invalid format: '" + message + "'", e.errorID);
                }
                else
                {
                    throw e;
                }
            }

            return  result;
        }

        public static function stringify(data:*):String
        {
            if (encode == null)
            {
                if (useLegacy)
                {
                    log.warn("Using JSON encoder workaround for AIR 2.6 [linux]");
                    encode = function (data:*):String
                    {
                        var encoder:Encoder = new Encoder(data);
                        return encoder.getString();
                    };
                }
                else
                {
                    log.info("Using native JSON encoder");
                    var json:Class = Types.getDefinitionByName("JSON") as Class;
                    encode = json["stringify"];
                }
            }

            return encode.call(null, data);
        }
    }
}


/*
 Copyright (c) 2008, Adobe Systems Incorporated
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.

 * Neither the name of Adobe Systems Incorporated nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


import avmplus.R;
import avmplus.Types;

import converter.rest.custom.DateUtil;

import mx.collections.ListCollectionView;

import mx.logging.ILogger;

import mx.logging.Log;

class Encoder
{

    private static const log:ILogger = Log.getLogger("JSON_Encoder");

    /** The string that is going to represent the object we're encoding */
    private var jsonString:String;

    /**
     * Creates a new JSONEncoder.
     *
     * @param o The object to encode as a JSON string
     * @langversion ActionScript 3.0
     * @playerversion Flash 9.0
     * @tiptext
     */
    public function Encoder(value:*)
    {
        jsonString = convertToString(value);
    }

    /**
     * Gets the JSON string from the encoder.
     *
     * @return The JSON string representation of the object
     *        that was passed to the constructor
     * @langversion ActionScript 3.0
     * @playerversion Flash 9.0
     * @tiptext
     */
    public function getString():String
    {
        return jsonString;
    }

    /**
     * Converts a value to it's JSON string equivalent.
     *
     * @param value The value to convert.  Could be any
     *        type (object, number, array, etc)
     */
    private function convertToString(value:*):String
    {
        // determine what value is and convert it based on it's type
        if (value is String)
        {
            // escape the string so it's formatted correctly
            return escapeString(value as String);
        }
        else if (value is Number)
        {
            // only encode numbers that finate
            return isFinite(value as Number) ? value.toString() : "null";
        }
        else if (value is Boolean)
        {
            // convert boolean to string easily
            return value ? "true" : "false";
        }
        else if (value is Array || isVector(Types.getQualifiedClassName(value)))
        {
            // call the helper method to convert an array
            return arrayToString(value);
        }
        else if (value is ListCollectionView)
        {
            // call the helper method to convert an array
            return collectionToString(value);
        }
        else if (value is Date)
        {
            return escapeString(DateUtil.toW3CDTF(value as Date));
        }
        else if (value is Object && value != null)
        {
            // call the helper method to convert an object
            return objectToString(value);
        }

        return "null";
    }

    /**
     * Escapes a string accoding to the JSON specification.
     *
     * @param str The string to be escaped
     * @return The string with escaped special characters
     *        according to the JSON specification
     */
    private function escapeString(str:String):String
    {
        // create a string to store the string's jsonstring value
        var s:String = "";
        // current character in the string we're processing
        var ch:String;
        // store the length in a local variable to reduce lookups
        var len:Number = str.length;

        // loop over all of the characters in the string
        for (var i:int = 0; i < len; i++)
        {
            // examine the character to determine if we have to escape it
            ch = str.charAt(i);
            switch (ch)
            {
                case '"': // quotation mark
                    s += "\\\"";
                    break;

                //case '/':	// solidus
                //	s += "\\/";
                //	break;

                case '\\': // reverse solidus
                    s += "\\\\";
                    break;

                case '\b': // bell
                    s += "\\b";
                    break;

                case '\f': // form feed
                    s += "\\f";
                    break;

                case '\n': // newline
                    s += "\\n";
                    break;

                case '\r': // carriage return
                    s += "\\r";
                    break;

                case '\t': // horizontal tab
                    s += "\\t";
                    break;

                default: // everything else

                    // check for a control character and escape as unicode
                    if (ch < ' ')
                    {
                        // get the hex digit(s) of the character (either 1 or 2 digits)
                        var hexCode:String = ch.charCodeAt(0).toString(16);

                        // ensure that there are 4 digits by adjusting
                        // the # of zeros accordingly.
                        var zeroPad:String = hexCode.length == 2 ? "00" : "000";

                        // create the unicode escape sequence with 4 hex digits
                        s += "\\u" + zeroPad + hexCode;
                    }
                    else
                    {

                        // no need to do any special encoding, just pass-through
                        s += ch;

                    }
            } // end switch

        } // end for loop

        return "\"" + s + "\"";
    }

    /**
     * Converts an array to it's JSON string equivalent
     *
     * @param a The array to convert
     * @return The JSON string representation of <code>a</code>
     */
    private function arrayToString(a:*):String
    {
        // create a string to store the array's jsonstring value
        var s:String = "";

        // loop over the elements in the array and add their converted
        // values to the string
        var length:int = a.length;
        for (var i:int = 0; i < length; i++)
        {
            // when the length is 0 we're adding the first element so
            // no comma is necessary
            if (s.length > 0)
            {
                // we've already added an element, so add the comma separator
                s += ","
            }

            // convert the value to a string
            s += convertToString(a[ i ]);
        }

        // KNOWN ISSUE:  In ActionScript, Arrays can also be associative
        // objects and you can put anything in them, ie:
        //		myArray["foo"] = "bar";
        //
        // These properties aren't picked up in the for loop above because
        // the properties don't correspond to indexes.  However, we're
        // sort of out luck because the JSON specification doesn't allow
        // these types of array properties.
        //
        // So, if the array was also used as an associative object, there
        // may be some values in the array that don't get properly encoded.
        //
        // A possible solution is to instead encode the Array as an Object
        // but then it won't get decoded correctly (and won't be an
        // Array instance)

        // close the array and return it's string value
        return "[" + s + "]";
    }

    private function collectionToString(a:*):String
    {
        // create a string to store the array's jsonstring value
        var s:String = "";

        // loop over the elements in the array and add their converted
        // values to the string
        var length:int = a.length;
        for (var i:int = 0; i < length; i++)
        {
            // when the length is 0 we're adding the first element so
            // no comma is necessary
            if (s.length > 0)
            {
                // we've already added an element, so add the comma separator
                s += ","
            }

            // convert the value to a string
            s += convertToString(a.getItemAt(i));
        }

        // KNOWN ISSUE:  In ActionScript, Arrays can also be associative
        // objects and you can put anything in them, ie:
        //		myArray["foo"] = "bar";
        //
        // These properties aren't picked up in the for loop above because
        // the properties don't correspond to indexes.  However, we're
        // sort of out luck because the JSON specification doesn't allow
        // these types of array properties.
        //
        // So, if the array was also used as an associative object, there
        // may be some values in the array that don't get properly encoded.
        //
        // A possible solution is to instead encode the Array as an Object
        // but then it won't get decoded correctly (and won't be an
        // Array instance)

        // close the array and return it's string value
        return "[" + s + "]";
    }

    /**
     * Converts an object to it's JSON string equivalent
     *
     * @param o The object to convert
     * @return The JSON string representation of <code>o</code>
     */
    private function objectToString(o:Object):String
    {
        // create a string to store the object's jsonstring value
        var s:String = "";

        // determine if o is a class instance or a plain object
        var classInfo:Object = R.describe(o, R.TRAITS | R.METADATA | R.VARIABLES | R.ACCESSORS);

        if (classInfo.name == "Object")
        {
            // the value of o[key] in the loop below - store this
            // as a variable so we don't have to keep looking up o[key]
            // when testing for valid values to convert
            var value:Object;

            // loop over the keys in the object and add their converted
            // values to the string
            for (var key:String in o)
            {
                // assign value to a variable for quick lookup
                value = o[ key ];

                // don't add function's to the JSON string
                if (value is Function)
                {
                    // skip this key and try another
                    continue;
                }

                // when the length is 0 we're adding the first item so
                // no comma is necessary
                if (s.length > 0)
                {
                    // we've already added an item, so add the comma separator
                    s += ","
                }

                s += escapeString(key) + ":" + convertToString(value);
            }
            return "{" + s + "}";
        }
        else if (!o.hasOwnProperty("toJSON"))// o is a class instance
        {
            // Loop over all of the variables and accessors in the class and
            // serialize them along with their values.

            var members:Array =  classInfo.traits.variables || [];
            var accessors:Array = classInfo.traits.accessors || [];

            members = members.concat(accessors.filter(function (item:Object, index:int, array:Array):Boolean
            {
                return item.access == "readwrite";
            }));

            for each (var v:Object in members)
            {
                var transient:Array = v.metadata.filter(function (item:Object, index:int, array:Array):Boolean
                {
                    return item && item.name == "Transient";
                });

                // Issue #110 - If [Transient] metadata exists, then we should skip
                if (transient.length > 0)
                {
                    continue;
                }

                // When the length is 0 we're adding the first item so
                // no comma is necessary
                if (s.length > 0)
                {
                    // We've already added an item, so add the comma separator
                    s += ","
                }

                s += escapeString(v.name) + ":" + convertToString(o[v.name]);
            }
            return "{" + s + "}";
        }
        else
        {
            var k:* = o.toJSON();
            s = k is String ? k : ((k is Array || isVector(Types.getQualifiedClassName(k))) ? arrayToString(k) : objectToString(k));
        }

        return  s;
    }

    public function isVector(classType:String):Boolean
    {
        return classType != null && classType.indexOf("__AS3__.vec::Vector") == 0;
    }
}

class JSONTokenType
{
    public static const UNKNOWN:int = -1;

    public static const COMMA:int = 0;

    public static const LEFT_BRACE:int = 1;

    public static const RIGHT_BRACE:int = 2;

    public static const LEFT_BRACKET:int = 3;

    public static const RIGHT_BRACKET:int = 4;

    public static const COLON:int = 6;

    public static const TRUE:int = 7;

    public static const FALSE:int = 8;

    public static const NULL:int = 9;

    public static const STRING:int = 10;

    public static const NUMBER:int = 11;

    public static const NAN:int = 12;

}

class JSONToken
{

    /**
     * The type of the token.
     *
     * @langversion ActionScript 3.0
     * @playerversion Flash 9.0
     * @tiptext
     */
    public var type:int;

    /**
     * The value of the token
     *
     * @langversion ActionScript 3.0
     * @playerversion Flash 9.0
     * @tiptext
     */
    public var value:Object;

    /**
     * Creates a new JSONToken with a specific token type and value.
     *
     * @param type The JSONTokenType of the token
     * @param value The value of the token
     * @langversion ActionScript 3.0
     * @playerversion Flash 9.0
     * @tiptext
     */
    public function JSONToken(type:int = -1 /* JSONTokenType.UNKNOWN */, value:Object = null)
    {
        this.type = type;
        this.value = value;
    }

    /**
     * Reusable token instance.
     *
     * @see #create()
     */
    internal static const token:JSONToken = new JSONToken();

    /**
     * Factory method to create instances.  Because we don't need more than one instance
     * of a token at a time, we can always use the same instance to improve performance
     * and reduce memory consumption during decoding.
     */
    internal static function create(type:int = -1 /* JSONTokenType.UNKNOWN */, value:Object = null):JSONToken
    {
        token.type = type;
        token.value = value;

        return token;
    }
}

class JSONTokenizer
{

    /**
     * Flag indicating if the tokenizer should only recognize
     * standard JSON tokens.  Setting to <code>false</code> allows
     * tokens such as NaN and allows numbers to be formatted as
     * hex, etc.
     */
    private var strict:Boolean;

    /** The object that will get parsed from the JSON string */
    private var obj:Object;

    /** The JSON string to be parsed */
    private var jsonString:String;

    /** The current parsing location in the JSON string */
    private var loc:int;

    /** The current character in the JSON string during parsing */
    private var ch:String;

    /**
     * The regular expression used to make sure the string does not
     * contain invalid control characters.
     */
    private const controlCharsRegExp:RegExp = /[\x00-\x1F]/;

    /**
     * Constructs a new JSONDecoder to parse a JSON string
     * into a native object.
     *
     * @param s The JSON string to be converted
     *        into a native object
     */
    public function JSONTokenizer(s:String, strict:Boolean)
    {
        jsonString = s;
        this.strict = strict;
        loc = 0;

        // prime the pump by getting the first character
        nextChar();
    }

    /**
     * Gets the next token in the input sting and advances
     * the character to the next character after the token
     */
    public function getNextToken():JSONToken
    {
        var token:JSONToken = null;

        // skip any whitespace / comments since the last
        // token was read
        skipIgnored();

        // examine the new character and see what we have...
        switch (ch)
        {
            case '{':
                token = JSONToken.create(JSONTokenType.LEFT_BRACE, ch);
                nextChar();
                break

            case '}':
                token = JSONToken.create(JSONTokenType.RIGHT_BRACE, ch);
                nextChar();
                break

            case '[':
                token = JSONToken.create(JSONTokenType.LEFT_BRACKET, ch);
                nextChar();
                break

            case ']':
                token = JSONToken.create(JSONTokenType.RIGHT_BRACKET, ch);
                nextChar();
                break

            case ',':
                token = JSONToken.create(JSONTokenType.COMMA, ch);
                nextChar();
                break

            case ':':
                token = JSONToken.create(JSONTokenType.COLON, ch);
                nextChar();
                break;

            case 't': // attempt to read true
                var possibleTrue:String = "t" + nextChar() + nextChar() + nextChar();

                if (possibleTrue == "true")
                {
                    token = JSONToken.create(JSONTokenType.TRUE, true);
                    nextChar();
                }
                else
                {
                    parseError("Expecting 'true' but found " + possibleTrue);
                }

                break;

            case 'f': // attempt to read false
                var possibleFalse:String = "f" + nextChar() + nextChar() + nextChar() + nextChar();

                if (possibleFalse == "false")
                {
                    token = JSONToken.create(JSONTokenType.FALSE, false);
                    nextChar();
                }
                else
                {
                    parseError("Expecting 'false' but found " + possibleFalse);
                }

                break;

            case 'n': // attempt to read null
                var possibleNull:String = "n" + nextChar() + nextChar() + nextChar();

                if (possibleNull == "null")
                {
                    token = JSONToken.create(JSONTokenType.NULL, null);
                    nextChar();
                }
                else
                {
                    parseError("Expecting 'null' but found " + possibleNull);
                }

                break;

            case 'N': // attempt to read NaN
                var possibleNaN:String = "N" + nextChar() + nextChar();

                if (possibleNaN == "NaN")
                {
                    token = JSONToken.create(JSONTokenType.NAN, NaN);
                    nextChar();
                }
                else
                {
                    parseError("Expecting 'NaN' but found " + possibleNaN);
                }

                break;

            case '"': // the start of a string
                token = readString();
                break;

            default:
                // see if we can read a number
                if (isDigit(ch) || ch == '-')
                {
                    token = readNumber();
                }
                else if (ch == '')
                {
                    // check for reading past the end of the string
                    token = null;
                }
                else
                {
                    // not sure what was in the input string - it's not
                    // anything we expected
                    parseError("Unexpected " + ch + " encountered");
                }
        }

        return token;
    }

    /**
     * Attempts to read a string from the input string.  Places
     * the character location at the first character after the
     * string.  It is assumed that ch is " before this method is called.
     *
     * @return the JSONToken with the string value if a string could
     *        be read.  Throws an error otherwise.
     */
    private final function readString():JSONToken
    {
        // Rather than examine the string character-by-character, it's
        // faster to use indexOf to try to and find the closing quote character
        // and then replace escape sequences after the fact.

        // Start at the current input stream position
        var quoteIndex:int = loc;
        do
        {
            // Find the next quote in the input stream
            quoteIndex = jsonString.indexOf("\"", quoteIndex);

            if (quoteIndex >= 0)
            {
                // We found the next double quote character in the string, but we need
                // to make sure it is not part of an escape sequence.

                // Keep looping backwards while the previous character is a backslash
                var backspaceCount:int = 0;
                var backspaceIndex:int = quoteIndex - 1;
                while (jsonString.charAt(backspaceIndex) == "\\")
                {
                    backspaceCount++;
                    backspaceIndex--;
                }

                // If we have an even number of backslashes, that means this is the ending quote
                if (( backspaceCount & 1 ) == 0)
                {
                    break;
                }

                // At this point, the quote was determined to be part of an escape sequence
                // so we need to move past the quote index to look for the next one
                quoteIndex++;
            }
            else // There are no more quotes in the string and we haven't found the end yet
            {
                parseError("Unterminated string literal");
            }
        } while (true);

        // Unescape the string
        // the token for the string we'll try to read
        var token:JSONToken = JSONToken.create(
                JSONTokenType.STRING,
                // Attach resulting string to the token to return it
                unescapeString(jsonString.substr(loc, quoteIndex - loc)));

        // Move past the closing quote in the input string.  This updates the next
        // character in the input stream to be the character one after the closing quote
        loc = quoteIndex + 1;
        nextChar();

        return token;
    }

    /**
     * Convert all JavaScript escape characters into normal characters
     *
     * @param input The input string to convert
     * @return Original string with escape characters replaced by real characters
     */
    public function unescapeString(input:String):String
    {
        // Issue #104 - If the string contains any unescaped control characters, this
        // is an error in strict mode
        if (strict && controlCharsRegExp.test(input))
        {
            parseError("String contains unescaped control character (0x00-0x1F)");
        }

        var result:String = "";
        var backslashIndex:int = 0;
        var nextSubstringStartPosition:int = 0;
        var len:int = input.length;
        do
        {
            // Find the next backslash in the input
            backslashIndex = input.indexOf('\\', nextSubstringStartPosition);

            if (backslashIndex >= 0)
            {
                result += input.substr(nextSubstringStartPosition, backslashIndex - nextSubstringStartPosition);

                // Move past the backslash and next character (all escape sequences are
                // two characters, except for \u, which will advance this further)
                nextSubstringStartPosition = backslashIndex + 2;

                // Check the next character so we know what to escape
                var escapedChar:String = input.charAt(backslashIndex + 1);
                switch (escapedChar)
                {
                    // Try to list the most common expected cases first to improve performance

                    case '"':
                        result += escapedChar;
                        break; // quotation mark
                    case '\\':
                        result += escapedChar;
                        break; // reverse solidus
                    case 'n':
                        result += '\n';
                        break; // newline
                    case 'r':
                        result += '\r';
                        break; // carriage return
                    case 't':
                        result += '\t';
                        break; // horizontal tab

                    // Convert a unicode escape sequence to it's character value
                    case 'u':

                        // Save the characters as a string we'll convert to an int
                        var hexValue:String = "";

                        var unicodeEndPosition:int = nextSubstringStartPosition + 4;

                        // Make sure there are enough characters in the string leftover
                        if (unicodeEndPosition > len)
                        {
                            parseError("Unexpected end of input.  Expecting 4 hex digits after \\u.");
                        }

                        // Try to find 4 hex characters
                        for (var i:int = nextSubstringStartPosition; i < unicodeEndPosition; i++)
                        {
                            // get the next character and determine
                            // if it's a valid hex digit or not
                            var possibleHexChar:String = input.charAt(i);
                            if (!isHexDigit(possibleHexChar))
                            {
                                parseError("Excepted a hex digit, but found: " + possibleHexChar);
                            }

                            // Valid hex digit, add it to the value
                            hexValue += possibleHexChar;
                        }

                        // Convert hexValue to an integer, and use that
                        // integer value to create a character to add
                        // to our string.
                        result += String.fromCharCode(parseInt(hexValue, 16));

                        // Move past the 4 hex digits that we just read
                        nextSubstringStartPosition = unicodeEndPosition;
                        break;

                    case 'f':
                        result += '\f';
                        break; // form feed
                    case '/':
                        result += '/';
                        break; // solidus
                    case 'b':
                        result += '\b';
                        break; // bell
                    default:
                        result += '\\' + escapedChar; // Couldn't unescape the sequence, so just pass it through
                }
            }
            else
            {
                // No more backslashes to replace, append the rest of the string
                result += input.substr(nextSubstringStartPosition);
                break;
            }

        } while (nextSubstringStartPosition < len);

        return result;
    }

    /**
     * Attempts to read a number from the input string.  Places
     * the character location at the first character after the
     * number.
     *
     * @return The JSONToken with the number value if a number could
     *        be read.  Throws an error otherwise.
     */
    private final function readNumber():JSONToken
    {
        // the string to accumulate the number characters
        // into that we'll convert to a number at the end
        var input:String = "";

        // check for a negative number
        if (ch == '-')
        {
            input += '-';
            nextChar();
        }

        // the number must start with a digit
        if (!isDigit(ch))
        {
            parseError("Expecting a digit");
        }

        // 0 can only be the first digit if it
        // is followed by a decimal point
        if (ch == '0')
        {
            input += ch;
            nextChar();

            // make sure no other digits come after 0
            if (isDigit(ch))
            {
                parseError("A digit cannot immediately follow 0");
            }
            // unless we have 0x which starts a hex number, but this
            // doesn't match JSON spec so check for not strict mode.
            else if (!strict && ch == 'x')
            {
                // include the x in the input
                input += ch;
                nextChar();

                // need at least one hex digit after 0x to
                // be valid
                if (isHexDigit(ch))
                {
                    input += ch;
                    nextChar();
                }
                else
                {
                    parseError("Number in hex format require at least one hex digit after \"0x\"");
                }

                // consume all of the hex values
                while (isHexDigit(ch))
                {
                    input += ch;
                    nextChar();
                }
            }
        }
        else
        {
            // read numbers while we can
            while (isDigit(ch))
            {
                input += ch;
                nextChar();
            }
        }

        // check for a decimal value
        if (ch == '.')
        {
            input += '.';
            nextChar();

            // after the decimal there has to be a digit
            if (!isDigit(ch))
            {
                parseError("Expecting a digit");
            }

            // read more numbers to get the decimal value
            while (isDigit(ch))
            {
                input += ch;
                nextChar();
            }
        }

        // check for scientific notation
        if (ch == 'e' || ch == 'E')
        {
            input += "e"
            nextChar();
            // check for sign
            if (ch == '+' || ch == '-')
            {
                input += ch;
                nextChar();
            }

            // require at least one number for the exponent
            // in this case
            if (!isDigit(ch))
            {
                parseError("Scientific notation number needs exponent value");
            }

            // read in the exponent
            while (isDigit(ch))
            {
                input += ch;
                nextChar();
            }
        }

        // convert the string to a number value
        var num:Number = Number(input);

        if (isFinite(num) && !isNaN(num))
        {
            // the token for the number that we've read
            return JSONToken.create(JSONTokenType.NUMBER, num);
        }
        else
        {
            parseError("Number " + num + " is not valid!");
        }

        return null;
    }

    /**
     * Reads the next character in the input
     * string and advances the character location.
     *
     * @return The next character in the input string, or
     *        null if we've read past the end.
     */
    private final function nextChar():String
    {
        return ch = jsonString.charAt(loc++);
    }

    /**
     * Advances the character location past any
     * sort of white space and comments
     */
    private final function skipIgnored():void
    {
        var originalLoc:int;

        // keep trying to skip whitespace and comments as long
        // as we keep advancing past the original location
        do
        {
            originalLoc = loc;
            skipWhite();
            skipComments();
        } while (originalLoc != loc);
    }

    /**
     * Skips comments in the input string, either
     * single-line or multi-line.  Advances the character
     * to the first position after the end of the comment.
     */
    private function skipComments():void
    {
        if (ch == '/')
        {
            // Advance past the first / to find out what type of comment
            nextChar();
            switch (ch)
            {
                case '/': // single-line comment, read through end of line

                    // Loop over the characters until we find
                    // a newline or until there's no more characters left
                    do
                    {
                        nextChar();
                    } while (ch != '\n' && ch != '')

                    // move past the \n
                    nextChar();

                    break;

                case '*': // multi-line comment, read until closing */

                    // move past the opening *
                    nextChar();

                    // try to find a trailing */
                    while (true)
                    {
                        if (ch == '*')
                        {
                            // check to see if we have a closing /
                            nextChar();
                            if (ch == '/')
                            {
                                // move past the end of the closing */
                                nextChar();
                                break;
                            }
                        }
                        else
                        {
                            // move along, looking if the next character is a *
                            nextChar();
                        }

                        // when we're here we've read past the end of
                        // the string without finding a closing */, so error
                        if (ch == '')
                        {
                            parseError("Multi-line comment not closed");
                        }
                    }

                    break;

                // Can't match a comment after a /, so it's a parsing error
                default:
                    parseError("Unexpected " + ch + " encountered (expecting '/' or '*' )");
            }
        }

    }


    /**
     * Skip any whitespace in the input string and advances
     * the character to the first character after any possible
     * whitespace.
     */
    private final function skipWhite():void
    {
        // As long as there are spaces in the input
        // stream, advance the current location pointer
        // past them
        while (isWhiteSpace(ch))
        {
            nextChar();
        }

    }

    /**
     * Determines if a character is whitespace or not.
     *
     * @return True if the character passed in is a whitespace
     *    character
     */
    private final function isWhiteSpace(ch:String):Boolean
    {
        // Check for the whitespace defined in the spec
        if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r')
        {
            return true;
        }
        // If we're not in strict mode, we also accept non-breaking space
        else if (!strict && ch.charCodeAt(0) == 160)
        {
            return true;
        }

        return false;
    }

    /**
     * Determines if a character is a digit [0-9].
     *
     * @return True if the character passed in is a digit
     */
    private final function isDigit(ch:String):Boolean
    {
        return ( ch >= '0' && ch <= '9' );
    }

    /**
     * Determines if a character is a hex digit [0-9A-Fa-f].
     *
     * @return True if the character passed in is a hex digit
     */
    private final function isHexDigit(ch:String):Boolean
    {
        return ( isDigit(ch) || ( ch >= 'A' && ch <= 'F' ) || ( ch >= 'a' && ch <= 'f' ) );
    }

    /**
     * Raises a parsing error with a specified message, tacking
     * on the error location and the original string.
     *
     * @param message The message indicating why the error occurred
     */
    public final function parseError(message:String):void
    {
        throw new Error(message + "," + loc + "," + jsonString);
    }
}

class Decoder
{
    /**
     * Flag indicating if the parser should be strict about the format
     * of the JSON string it is attempting to decode.
     */
    private var strict:Boolean;

    /** The value that will get parsed from the JSON string */
    private var value:*;

    /** The tokenizer designated to read the JSON string */
    private var tokenizer:JSONTokenizer;

    /** The current token from the tokenizer */
    private var token:JSONToken;

    /**
     * Constructs a new JSONDecoder to parse a JSON string
     * into a native object.
     *
     * @param s The JSON string to be converted
     *        into a native object
     * @param strict Flag indicating if the JSON string needs to
     *        strictly match the JSON standard or not.
     * @langversion ActionScript 3.0
     * @playerversion Flash 9.0
     * @tiptext
     */
    public function Decoder(s:String, strict:Boolean)
    {
        this.strict = strict;
        tokenizer = new JSONTokenizer(s, strict);

        nextToken();
        value = parseValue();

        // Make sure the input stream is empty
        if (strict && nextToken() != null)
        {
            tokenizer.parseError("Unexpected characters left in input stream");
        }
    }

    /**
     * Gets the internal object that was created by parsing
     * the JSON string passed to the constructor.
     *
     * @return The internal object representation of the JSON
     *        string that was passed to the constructor
     * @langversion ActionScript 3.0
     * @playerversion Flash 9.0
     * @tiptext
     */
    public function getValue():*
    {
        return value;
    }

    /**
     * Returns the next token from the tokenzier reading
     * the JSON string
     */
    private final function nextToken():JSONToken
    {
        return token = tokenizer.getNextToken();
    }

    /**
     * Returns the next token from the tokenizer reading
     * the JSON string and verifies that the token is valid.
     */
    private final function nextValidToken():JSONToken
    {
        token = tokenizer.getNextToken();
        checkValidToken();

        return token;
    }

    /**
     * Verifies that the token is valid.
     */
    private final function checkValidToken():void
    {
        // Catch errors when the input stream ends abruptly
        if (token == null)
        {
            tokenizer.parseError("Unexpected end of input");
        }
    }

    /**
     * Attempt to parse an array.
     */
    private final function parseArray():Array
    {
        // create an array internally that we're going to attempt
        // to parse from the tokenizer
        var a:Array = new Array();

        // grab the next token from the tokenizer to move
        // past the opening [
        nextValidToken();

        // check to see if we have an empty array
        if (token.type == JSONTokenType.RIGHT_BRACKET)
        {
            // we're done reading the array, so return it
            return a;
        }
        // in non-strict mode an empty array is also a comma
        // followed by a right bracket
        else if (!strict && token.type == JSONTokenType.COMMA)
        {
            // move past the comma
            nextValidToken();

            // check to see if we're reached the end of the array
            if (token.type == JSONTokenType.RIGHT_BRACKET)
            {
                return a;
            }
            else
            {
                tokenizer.parseError("Leading commas are not supported.  Expecting ']' but found " + token.value);
            }
        }

        // deal with elements of the array, and use an "infinite"
        // loop because we could have any amount of elements
        while (true)
        {
            // read in the value and add it to the array
            a.push(parseValue());

            // after the value there should be a ] or a ,
            nextValidToken();

            if (token.type == JSONTokenType.RIGHT_BRACKET)
            {
                // we're done reading the array, so return it
                return a;
            }
            else if (token.type == JSONTokenType.COMMA)
            {
                // move past the comma and read another value
                nextToken();

                // Allow arrays to have a comma after the last element
                // if the decoder is not in strict mode
                if (!strict)
                {
                    checkValidToken();

                    // Reached ",]" as the end of the array, so return it
                    if (token.type == JSONTokenType.RIGHT_BRACKET)
                    {
                        return a;
                    }
                }
            }
            else
            {
                tokenizer.parseError("Expecting ] or , but found " + token.value);
            }
        }

        return null;
    }

    /**
     * Attempt to parse an object.
     */
    private final function parseObject():Object
    {
        // create the object internally that we're going to
        // attempt to parse from the tokenizer
        var o:Object = new Object();

        // store the string part of an object member so
        // that we can assign it a value in the object
        var key:String

        // grab the next token from the tokenizer
        nextValidToken();

        // check to see if we have an empty object
        if (token.type == JSONTokenType.RIGHT_BRACE)
        {
            // we're done reading the object, so return it
            return o;
        }
        // in non-strict mode an empty object is also a comma
        // followed by a right bracket
        else if (!strict && token.type == JSONTokenType.COMMA)
        {
            // move past the comma
            nextValidToken();

            // check to see if we're reached the end of the object
            if (token.type == JSONTokenType.RIGHT_BRACE)
            {
                return o;
            }
            else
            {
                tokenizer.parseError("Leading commas are not supported.  Expecting '}' but found " + token.value);
            }
        }

        // deal with members of the object, and use an "infinite"
        // loop because we could have any amount of members
        while (true)
        {
            if (token.type == JSONTokenType.STRING)
            {
                // the string value we read is the key for the object
                key = String(token.value);

                // move past the string to see what's next
                nextValidToken();

                // after the string there should be a :
                if (token.type == JSONTokenType.COLON)
                {
                    // move past the : and read/assign a value for the key
                    nextToken();
                    o[ key ] = parseValue();

                    // move past the value to see what's next
                    nextValidToken();

                    // after the value there's either a } or a ,
                    if (token.type == JSONTokenType.RIGHT_BRACE)
                    {
                        // we're done reading the object, so return it
                        return o;
                    }
                    else if (token.type == JSONTokenType.COMMA)
                    {
                        // skip past the comma and read another member
                        nextToken();

                        // Allow objects to have a comma after the last member
                        // if the decoder is not in strict mode
                        if (!strict)
                        {
                            checkValidToken();

                            // Reached ",}" as the end of the object, so return it
                            if (token.type == JSONTokenType.RIGHT_BRACE)
                            {
                                return o;
                            }
                        }
                    }
                    else
                    {
                        tokenizer.parseError("Expecting } or , but found " + token.value);
                    }
                }
                else
                {
                    tokenizer.parseError("Expecting : but found " + token.value);
                }
            }
            else
            {
                tokenizer.parseError("Expecting string but found " + token.value);
            }
        }
        return null;
    }

    /**
     * Attempt to parse a value
     */
    private final function parseValue():Object
    {
        checkValidToken();

        switch (token.type)
        {
            case JSONTokenType.LEFT_BRACE:
                return parseObject();

            case JSONTokenType.LEFT_BRACKET:
                return parseArray();

            case JSONTokenType.STRING:
            case JSONTokenType.NUMBER:
            case JSONTokenType.TRUE:
            case JSONTokenType.FALSE:
            case JSONTokenType.NULL:
                return token.value;

            case JSONTokenType.NAN:
                if (!strict)
                {
                    return token.value;
                }
                else
                {
                    tokenizer.parseError("Unexpected " + token.value);
                }

            default:
                tokenizer.parseError("Unexpected " + token.value);

        }

        return null;
    }
}



