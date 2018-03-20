/*
 * author: alex
 *   date: 2018-03-02
 *   file: IZBTransportPacketHandler.h
 *   desc: 传输包处理接口类
 */

#pragma once

//#pragma pack(push, 1)

#include "ZBTaskDef.h"
#include <json/json/json.h>
#include <string>

using namespace std;

//typedef struct _tagTransportHeader {
//	unsigned int length;		// 报文长度（不包括本身长度），4 byte（高位先存）
//	unsigned char shiftKey;		// 移位加密key，1 byte
//	unsigned char remote;		// 客户端无用（直接传0），1 byte
//	unsigned char request;		// 客户端无用（直接传0），1 byte
//	int cmd;					// 命令号，区分不同请求及推送，4 byte（高位先存）
//	unsigned int seq;			// 序列号，用于标示相同cmd的多次请求，4 byte（高位先存）
//	unsigned char zip;			// data数据是否使用zip编码压缩（1：压缩，0：不压缩），1 byte
//	unsigned char protocolType;	// data数据格式（0：JSON，1：AMF），1 byte
//
//	_tagTransportHeader() {
//		length = 0;
//		shiftKey = 0;
//		remote = 0;
//		request = 0;
//		cmd = TCMD_UNKNOW;
//		seq = 0;
//		zip = 0;
//		protocolType = JSON_PROTOCOL;
//	}
//} TransportHeader;

class ZBTransportProtocol
{
public:
    ZBTransportProtocol() {
        clear();
    }
    ~ZBTransportProtocol() {};
    
//	TransportHeader header;		// 协议头
//	unsigned char data[1];		// 数据，长度为 header.length + sizeof(header.length) - sizeof(header)
//
//	unsigned int GetDataLength() const {
//		return header.length + sizeof(header.length) - sizeof(header);
//	}
//	void SetDataLength(unsigned int dataLength) {
//		header.length = sizeof(header) - sizeof(header.length) + dataLength;
//	}
public:
    void clear() {
        m_isRespond = false;
        m_reqId = 0;
        m_errno = (int)ZBLCC_ERR_PROTOCOLFAIL;
        m_errmsg = "";
        m_data.clear();
        m_dataNull = 0;
    }
    
public:
    bool        m_isRespond;    // 是否返回
    SEQ_T       m_reqId;      // 请求ID，请求唯一标识(自增)
    string      m_cmd;          // 命令号
    int         m_errno;        // 错误码
    string      m_errmsg;       // 错误描述
    Json::Value m_data;         // req_data/res_data
    int         m_dataNull;
};

//typedef struct _tagNoHeadTransportProtocol {
//	unsigned int data;		// 数据段
//
//	unsigned int GetAllDataLength() const {
//		return sizeof(data);
//	}
//} NoHeadTransportProtocol;

typedef enum {
	ZBUNPACKET_ERROR = -2,	// 严重错误，需要重新连接
	ZBUNPACKET_FAIL = -1,		// 解包失败
	ZBUNPACKET_SUCCESS = 0,	// 解包成功
	ZBUNPACKET_MOREDATA,		// 数据不足，需要接收更多数据
} ZBUNPACKET_RESULT_TYPE;

class IZBTask;
class IZBTransportPacketHandler
{
public:
	static IZBTransportPacketHandler* Create();
	static void Release(IZBTransportPacketHandler* handler);

public:
	IZBTransportPacketHandler(void) {};
	virtual ~IZBTransportPacketHandler(void) {};

public:
	// 组包
	virtual bool Packet(IZBTask* task, void* data, size_t dataSize, size_t& dataLen) = 0;
	// 解包
	virtual ZBUNPACKET_RESULT_TYPE Unpacket(const void* data, size_t dataLen, ZBTransportProtocol& tp) = 0;
};

//#pragma pack(pop)
