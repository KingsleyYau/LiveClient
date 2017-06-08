/*
 * File         : Arithmetic.hpp
 * Date         : 2007-07-12
 * Author       : Keqin Su
 * Copyright    : City Hotspot Co., Ltd.
 * Description  : include file for Arithmetic.h
 */

#ifndef _INC_ARITHMETIC
#define _INC_ARITHMETIC

#include <stdio.h>
#include <stdlib.h>

#include <string>
using namespace std;

class Arithmetic
{
public:
    static int TeaEncode(char* p_in, int i_in_len, char* p_key, char* p_out);
    static int TeaDecode(char* p_in, int i_in_len, char* p_key, char* p_out);

    static int Base64Encode(const char* data, int length, char** code);
	static int Base64Decode(const char* data, int length, char* code);
	static string Base64Encode(const char* data, int length);

    static int AsciiToHex(const char* data, int i_in_len, char* code);
    static int HexToAscii(const char* data, int i_in_len, char* code);

    static string AsciiToHexWithSep(const unsigned char* data, int i_in_len);

    static int encode_url(const char* data, int length, char *code);
    static int decode_url(const char* data, int length, char *code);

    static int encode_urlspecialchar(const char* data, int length, char* code);
    static int decode_urlspecialchar(const char* data, int length, char* code);

    static unsigned long MakeCRC32(char* data, int i_in_len);
    
    static bool String2Mac(char* pstr, char* Mac);
    static bool Mac2String(char* pstr, char* Mac);
    
    static string AesEncrypt(string initKey, string src);
    static string AesDecrypt(string initKey, string src);

    static size_t ChangeCharset(char* outbuf, size_t outbytes, const char* inbuf, const char* fromcode, const char* tocode, bool conv_begin = true);

protected:
    static void encipher(void* aData, const void* aKey);
    static void decipher(void* aData, const void* aKey);

protected:
    static char hex[16];
    static int encode[64];
    static char rstr[128];
    static unsigned long crc_32_tab[256];
};

#endif
