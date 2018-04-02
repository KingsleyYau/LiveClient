/*
 * AmfParser.cpp
 *
 *  Created on: 2015-3-16
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "AmfParser.h"

AmfParser::AmfParser() {
	// TODO Auto-generated constructor stub
	init_context(&mContext, AmfReadHandle, AmfWriteHandle);
	mpParseBuffer = NULL;
	miCurrentCapacity = 0;
	InitParseBuffer();
}

AmfParser::~AmfParser() {
	// TODO Auto-generated destructor stub
	clear_context(&mContext);

	if( mpParseBuffer != NULL ) {
		delete[] mpParseBuffer;
		mpParseBuffer = NULL;
	}
}

void AmfParser::InitParseBuffer() {
	if( mpParseBuffer == NULL ) {
		mpParseBuffer = new char[MAX_PARSE_BUFFER];
		miCurrentCapacity = MAX_PARSE_BUFFER;
	}

	miCurrentSize = 0;
	miCurrentHandleIndex = 0;
	mpParseBuffer[miCurrentSize] = '\0';
}

bool AmfParser::AddParseBuffer(const char* buf, size_t size) {
	bool bFlag = false;
	/* Add buffer if buffer is not enough */
	while( size + miCurrentSize > miCurrentCapacity ) {
		miCurrentCapacity *= 2;
		bFlag = true;
	}
	if( bFlag ) {
		char *newBuffer = new char[miCurrentCapacity];
		if( mpParseBuffer != NULL ) {
			memcpy(newBuffer, mpParseBuffer, miCurrentSize);
			delete[] mpParseBuffer;
			mpParseBuffer = NULL;
		}
		mpParseBuffer = newBuffer;
	}
	memcpy(mpParseBuffer + miCurrentSize, buf, size);
	miCurrentSize += size;
	mpParseBuffer[miCurrentSize] = '\0';
	return true;
}

amf_object_handle AmfParser::Decode(char* buf, size_t size) {
	InitParseBuffer();
	AddParseBuffer(buf, size);
	return decode(&mContext, this);
}
void AmfParser::Encode(amf_object_handle obj, const char** buffer, size_t &size) {
	InitParseBuffer();
	encode(&mContext, this, obj);
	*buffer = mpParseBuffer;
	size = miCurrentSize;
}

int AmfParser::ReadHandle(unsigned char* buffer, size_t size) {
	int read = -1;
	if( miCurrentHandleIndex + size <= miCurrentSize ) {
		memcpy(buffer, mpParseBuffer + miCurrentHandleIndex, size);
		miCurrentHandleIndex += size;
		read = size;
	}
	return read;
}

void AmfParser::WriteHandle(const unsigned char* buffer, size_t size) {
	AddParseBuffer((const char* )buffer, size);
}

int AmfParser::AmfReadHandle(void* data, size_t size, unsigned char* buffer) {
	AmfParser* parse = (AmfParser *)data;

	return parse->ReadHandle(buffer, size);
}

void AmfParser::AmfWriteHandle(void* data, const unsigned char* buffer, size_t size) {
	AmfParser* parse = (AmfParser *)data;
	return parse->WriteHandle(buffer, size);
}
