//
//  CacheBufferQueue.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "CacheBufferQueue.h"

namespace coollive {
CacheBufferQueue::CacheBufferQueue() {
    mMaxBufferCount = 100;
}

CacheBufferQueue::CacheBufferQueue(int maxBufferCount) {
    mMaxBufferCount = maxBufferCount;
}

CacheBufferQueue::~CacheBufferQueue() {
}

void CacheBufferQueue::SetCacheQueueSize(int maxBufferCount) {
    mMaxBufferCount = maxBufferCount;
}

void* CacheBufferQueue::PopBuffer() {
    void* buffer = NULL;
    
    mBufferList.lock();
    if( !mBufferList.empty() ) {
        buffer = (void *)mBufferList.front();
        if( buffer ) {
            mBufferList.pop_front();
        }
    }
    mBufferList.unlock();
    
    return buffer;
}

bool CacheBufferQueue::PushBuffer(void* buffer) {
    bool bFlag = false;
    
    mBufferList.lock();
    size_t size = (size_t)mBufferList.size();
    if( size < mMaxBufferCount ) {
        mBufferList.push_back(buffer);
        bFlag = true;
    }
    mBufferList.unlock();
    
    return bFlag;
}
}
