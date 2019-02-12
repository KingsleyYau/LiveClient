/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ILSLiveChatTransportPacketHandler.h
 *   desc: 传输包处理接口类
 */

#pragma once

#include "LSLiveChatTaskDef.h"

#pragma pack(push, 1)
typedef struct _tagLSLiveChatTransportHeader {
	unsigned int length;		// 报文长度（不包括本身长度），4 byte（高位先存）
	unsigned char shiftKey;		// 移位加密key，1 byte
	unsigned char remote;		// 客户端无用（直接传0），1 byte
	unsigned char request;		// 客户端无用（直接传0），1 byte
	int cmd;					// 命令号，区分不同请求及推送，4 byte（高位先存）
	unsigned int seq;			// 序列号，用于标示相同cmd的多次请求，4 byte（高位先存）
	unsigned char zip;			// data数据是否使用zip编码压缩（1：压缩，0：不压缩），1 byte
	unsigned char protocolType;	// data数据格式（0：JSON，1：AMF），1 byte

	_tagLSLiveChatTransportHeader() {
		length = 0;
		shiftKey = 0;
		remote = 0;
		request = 0;
		cmd = TCMD_UNKNOW;
		seq = 0;
		zip = 0;
		protocolType = JSON_PROTOCOL;
	}
} LSLiveChatTransportHeader;

typedef struct _tagLSLiveChatTransportProtocol {
	LSLiveChatTransportHeader header;		// 协议头
	unsigned char data[1];		// 数据，长度为 header.length + sizeof(header.length) - sizeof(header)

	unsigned int GetDataLength() const {
		return header.length + sizeof(header.length) - sizeof(header);
	}
	void SetDataLength(unsigned int dataLength) {
		header.length = sizeof(header) - sizeof(header.length) + dataLength;
	}
} LSLiveChatTransportProtocol;

typedef struct _tagLSLiveChatNoHeadTransportProtocol {
	unsigned int data;		// 数据段

	unsigned int GetAllDataLength() const {
		return sizeof(data);
	}
} LSLiveChatNoHeadTransportProtocol;
#pragma pack(pop)

typedef enum {
	UNPACKET_ERROR = -2,	// 严重错误，需要重新连接
	UNPACKET_FAIL = -1,		// 解包失败
	UNPACKET_SUCCESS = 0,	// 解包成功
	UNPACKET_MOREDATA,		// 数据不足，需要接收更多数据
} UNPACKET_RESULT_TYPE;

class ILSLiveChatTask;
class ILSLiveChatTransportPacketHandler
{
public:
	static ILSLiveChatTransportPacketHandler* Create();
	static void Release(ILSLiveChatTransportPacketHandler* handler);

public:
	ILSLiveChatTransportPacketHandler(void) {};
	virtual ~ILSLiveChatTransportPacketHandler(void) {};

public:
	// 组包
	virtual bool Packet(ILSLiveChatTask* task, void* data, unsigned int dataSize, unsigned int& dataLen) = 0;
	// 解包
	virtual UNPACKET_RESULT_TYPE Unpacket(void* data, unsigned int dataLen, unsigned int maxLen, LSLiveChatTransportProtocol** ppTp, unsigned int& useLen) = 0;

};
