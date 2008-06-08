package com.maclema.mysql
{   
    import flash.utils.ByteArray;
    
    /**
     * @private
     * This is an extension of the ByteArray to provide helper
     * methods specific to the MySQL client/server protocol.
     **/
    internal class Buffer extends ByteArray
    {	
        public function Buffer()
        {
            super();
        }
        
        /**
         * Writes n number of null bytes
         **/
        public function writeNullBytes(len:int):void
        {
            for ( var i:int=0; i<len; i++ )
            {
                writeByte(0x00);
            }
        }
        
        /**
         * Writes a three byte integer
         **/
        public function writeThreeByteInt(value:int):void
        {
            writeByte( value & 0xff );
            writeByte( value >>> 8 );
            writeByte( value >>> 16 );
        }
        
        /**
         * Reads a three byte integer
         **/
        public function readThreeByteInt():int
        {
            var n:int = ((readByte() & 0xff)) |
                        ((readByte() & 0xff) << 8) |
                        ((readByte() & 0xff) << 16);
                        
            return n;
        }
        
        /**
         * Writes a two byte integer
         **/
        public function writeTwoByteInt(value:int):void
        {
            writeByte( value & 0xff );
            writeByte( value >>> 8 );
        }
        
        /**
         * Reads a two byte integer
         **/
        public function readTwoByteInt():int
        {
            var n:int = ((readByte() & 0xff)) |
                        ((readByte() & 0xff) << 8);
                        
            return n;
        }
        
        /**
         * Reads a null-terminated string
         **/
        public function readString():String
        {
            var byte:int;
            var bytes:ByteArray = new ByteArray();
            while ( (byte=readByte()) != 0x00 )
            {
                bytes.writeByte(byte & 0xFF);
            }
            bytes.position = 0;
            return bytes.readUTFBytes(bytes.length);
        }
        
        public function writeString(string:String):void
        {
        	writeUTFBytes(string);
        	writeByte(0x00);
        }
        
        /**
         * Reades a length coded number
         **/
        public function readLengthCodedBinary():Number
        {
            var firstByte:int = (readByte() & 0xFF);
            
            if ( firstByte <= 250 )
            {
                return firstByte;
            }
                
            if ( firstByte == 251 )
            {
                return 0; // column value = NULL, only appropriate in a Row Data Packet
            }
            
            if ( firstByte == 252 )
            {
                return  ((readByte() & 0xff)) |
                        ((readByte() & 0xff) << 8);
            }
            
            if ( firstByte == 253 )
            {
                return  ((readByte() & 0xff)) |
                        ((readByte() & 0xff) << 8) |
                        ((readByte() & 0xff) << 16);
            }
            
            if ( firstByte == 254 )
            {
                return  ((readByte() & 0xff)) |
                        ((readByte() & 0xff) << 8) |
                        ((readByte() & 0xff) << 16) |
                        ((readByte() & 0xff) << 24) |
                        ((readByte() & 0xff) << 32) |
                        ((readByte() & 0xff) << 40) |
                        ((readByte() & 0xff) << 48) |
                        ((readByte() & 0xff) << 56);
            }
            
            throw new Error("Unknown Length Coded Binary");
        }
        
        /**
         * Reades a length-coded string
         **/
        public function readLengthCodedString():String
        {
            var len:Number = readLengthCodedBinary();
            
            if ( len == 0 )
            {
                return null;
            }
            
            return readUTFBytes(len);
        }
        
        public function readLengthCodedData():ByteArray
        {
            var len:Number = readLengthCodedBinary();
            
            if ( len == 0 )
            {
                return null;
            }
            
            var out:ByteArray = new ByteArray();
			readBytes( out, 0, len );
			
			return out;
        }
    }
}