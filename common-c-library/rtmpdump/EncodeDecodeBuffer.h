/*
 * EncodeDecodeBuffer.h
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#ifndef RTMPDUMP_EncodeDecodeBuffer_H_
#define RTMPDUMP_EncodeDecodeBuffer_H_

#include <stdio.h>

#include <common/list_lock.h>

class EncodeDecodeBuffer {
public:
	EncodeDecodeBuffer();
	virtual ~EncodeDecodeBuffer();

public:
    // 获取buffer指针
    unsigned char* GetBuffer() const;
    // 覆盖Buffer
    bool SetBuffer(const unsigned char* buffer, int bufferLen);
    // 添加Buffer
    bool AddBuffer(const unsigned char* buffer, int bufferLen);
    // 重置缓存数据
    bool RenewBufferSize(int bufferLen);

    // 重置参数
    void ResetFrame();

private:
    // 释放空间
    inline void ReleaseBuffer();

private:
    unsigned char* mBuffer;     // 数据缓存
    int mBufferSize;            // 数据空间长度

public:
    int mBufferLen;             // 数据已用长度
    unsigned int mTimestamp;    // 帧时间戳

};

// list define
typedef list_lock<EncodeDecodeBuffer*> EncodeDecodeBufferList;

#endif /* RTMPDUMP_EncodeDecodeBuffer_H_ */
