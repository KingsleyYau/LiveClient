/*
 * AmfParser.h
 *
 *  Created on: 2015-3-16
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef AMFPARSER_H_
#define AMFPARSER_H_

#include "AMF3.h"
using namespace AMF3;

#define MAX_PARSE_BUFFER 4 * 1024

class AmfParser {
public:
	AmfParser();
	virtual ~AmfParser();

	amf_object_handle Decode(char* buf, size_t size);
	void Encode(amf_object_handle obj, const char** buffer, size_t &size);

private:
	static int AmfReadHandle(void* data, size_t size, unsigned char* buffer);
	static void AmfWriteHandle(void* data, const unsigned char* buffer, size_t size);

	int ReadHandle(unsigned char* buffer, size_t size);
	void WriteHandle(const unsigned char* buffer, size_t size);

	void InitParseBuffer();
	bool AddParseBuffer(const char* buf, size_t size);

	context mContext;

	char* mpParseBuffer;
	unsigned int miCurrentSize;
	unsigned int miCurrentHandleIndex;
	unsigned int miCurrentCapacity;
};

#endif /* AMFPARSER_H_ */
