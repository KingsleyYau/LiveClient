/*
 * EncodeDecodeBuffer.h
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#ifndef RTMPDUMP_EncodeDecodeBuffer_H_
#define RTMPDUMP_EncodeDecodeBuffer_H_

#include <stdio.h>
#include <string.h>

#include <common/list_lock.h>

namespace coollive {
class EncodeDecodeBuffer {
public:
	EncodeDecodeBuffer();
	virtual ~EncodeDecodeBuffer();

    EncodeDecodeBuffer(const EncodeDecodeBuffer& item);
    EncodeDecodeBuffer& operator=(const EncodeDecodeBuffer& item);
    
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
    void ResetBuffer();
    // 填充Buffer
    void FillBufferWithChar(char c);
    // 获取当前容量
    int GetBufferCapacity();
    
public:
    int mBufferLen;             // 数据已用长度
    unsigned int mTimestamp;    // 帧时间戳
    
private:
    // 释放空间
    inline void ReleaseBuffer();

private:
    unsigned char* mBuffer;     // 数据缓存
    int mBufferSize;            // 数据空间长度

};

// list define
typedef list_lock<EncodeDecodeBuffer*> EncodeDecodeBufferList;
}

#endif /* RTMPDUMP_EncodeDecodeBuffer_H_ */
