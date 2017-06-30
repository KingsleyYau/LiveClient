//
//  CacheBufferQueue.h
//  RtmpClient
//
//  Created by Max on 2017/4/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef CacheBufferQueue_h
#define CacheBufferQueue_h

#include <stdio.h>

#include <common/list_lock.h>

namespace coollive {
class CacheBufferQueue {
public:
    CacheBufferQueue();
    CacheBufferQueue(int maxBufferCount);
    ~CacheBufferQueue();

public:
    /**
     * 设置最大缓存
     */
    void SetCacheQueueSize(int maxBufferCount);
    
    /**
     * 获取一个临时Buffer
     * @return true:缓存的Buffer/NULL:没有缓存的Buffer
     */
    void* PopBuffer();
    
    /**
     * 归还一个Buffer
     * @return true:成功归还/false:队列已满
     */
    bool PushBuffer(void *);
    
private:
    // 最大缓存Buffer
    int mMaxBufferCount;
    
    // Buffer队列
    list_lock<void *> mBufferList;
    
};
}
#endif /* CacheBufferQueue_h */
