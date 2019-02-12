/*
 * EncodeDecodeBuffer.cpp
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#include "EncodeDecodeBuffer.h"

#include <common/KLog.h>

namespace coollive {
EncodeDecodeBuffer::EncodeDecodeBuffer()
{
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "EncodeDecodeBuffer::EncodeDecodeBuffer( this : %p )", this);
    
    mBuffer = NULL;
    mBufferLen = 0;
    mBufferSize = 0;
    mTimestamp = 0;
}

EncodeDecodeBuffer::~EncodeDecodeBuffer()
{
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "EncodeDecodeBuffer::~EncodeDecodeBuffer( this : %p )", this);
    
    // 释放缓存
    ReleaseBuffer();
}

EncodeDecodeBuffer::EncodeDecodeBuffer(const EncodeDecodeBuffer& item) {
    mBuffer = NULL;
    mBufferLen = 0;
    mBufferSize = 0;

    mTimestamp = item.mTimestamp;
}
    
EncodeDecodeBuffer& EncodeDecodeBuffer::operator=(const EncodeDecodeBuffer& item) {
    if (this == &item) {
        return *this;
    }
    
    mTimestamp = item.mTimestamp;
    
    return *this;
}
    
// 获取buffer指针
unsigned char* EncodeDecodeBuffer::GetBuffer() const
{
    return mBuffer;
}

// 覆盖Buffer
bool EncodeDecodeBuffer::SetBuffer(const unsigned char* buffer, int bufferLen)
{
    bool result = false;
    if (bufferLen > 0 && NULL != buffer) {
        // 确保缓存足够
        if (RenewBufferSize(bufferLen)) {
            // 复制缓存
            memcpy(mBuffer, buffer, bufferLen);
            mBufferLen = bufferLen;

            result = true;
        }
    }
    return result;
}

// 添加Buffer
bool EncodeDecodeBuffer::AddBuffer(const unsigned char* buffer, int bufferLen)
{
    bool result = false;
    if (bufferLen > 0 && NULL != buffer) {
        // 确保缓存足够
        if (RenewBufferSize(mBufferLen + bufferLen)) {
            // 复制缓存
            memcpy(mBuffer + mBufferLen, buffer, bufferLen);
            mBufferLen += bufferLen;

            result = true;
        }
    }
    return result;
}

void EncodeDecodeBuffer::ResetBuffer()
{
    mBufferLen = 0;
    mTimestamp = 0;
}

void EncodeDecodeBuffer::FillBufferWithChar(char c) {
    if( mBuffer && mBufferSize > 0 ) {
        memset(mBuffer, c, mBufferSize);
    }
}
    
int EncodeDecodeBuffer::GetBufferCapacity() {
    return mBufferSize;
}
    
bool EncodeDecodeBuffer::RenewBufferSize(int bufferLen)
{
    bool result = true;

    // 若缓存空间不够大，则重建缓存
    if (bufferLen > mBufferSize) {
        // 获取旧缓存
        unsigned char* oldBuffer = mBuffer;
        int oldBufferLen = mBufferLen;

        // 重建缓存
        mBuffer = new unsigned char[bufferLen];
        if (NULL != mBuffer) {
            mBufferSize = bufferLen;
            mBufferLen = 0;
        }
        else {
            // 重建失败
            mBufferSize = 0;
            mBufferLen = 0;
            result = false;
        }

        // 复制缓存
        if (result
            && NULL != oldBuffer && oldBufferLen > 0)
        {
            memcpy(mBuffer, oldBuffer, oldBufferLen);
            mBufferLen = oldBufferLen;
        }

        // 释放旧缓存
        if( oldBuffer ) {
        	delete[] oldBuffer;
        }
    }

    return result;
}

// 释放空间
void EncodeDecodeBuffer::ReleaseBuffer()
{
	if( mBuffer ) {
		delete[] mBuffer;
		mBuffer = NULL;
	}

    mBufferSize = 0;
    mBufferLen = 0;
}
}
