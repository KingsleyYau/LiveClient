/*
 * IAutoLockWrapper.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */
#include "IAutoLockWrapper.h"
#include "IAutoLock.h"
#include "KLogWrapper.h"
//#define PRINTLOG(fileNamePre, format, ...)  FileLevelLog(fileNamePre, KLog::LOG_WARNING, format,  ## __VA_ARGS__)
#ifdef __cplusplus
extern "C" {
#endif
    struct IAutoLockTag
    {
        IAutoLock* tagLock = 0;
    };
    
    struct IAutoLockTag *GetNewAutoLock(void) {
        IAutoLockTag* tag = new struct IAutoLockTag;
        PrintLog(__FUNCTION__, "mongoose::GetNewAutoLock:%p begin", tag);
        if (tag != 0) {
            PrintLog(__FUNCTION__, "mongoose::GetNewAutoLock:%p tag->tagLock:%p begin", tag, tag->tagLock);
            tag->tagLock = IAutoLock::CreateAutoLock();
            tag->tagLock->Init(IAutoLock::IAutoLockType_Recursive);
            PrintLog(__FUNCTION__, "mongoose::GetNewAutoLock:%p tag->tagLock:%p end", tag, tag->tagLock);
        }
         PrintLog(__FUNCTION__, "mongoose::GetNewAutoLock:%p end", tag);
        return tag;
    }
    
    void ReleaseAutoLock(struct IAutoLockTag ** ppInstance) {
        if ((*ppInstance)->tagLock) {
            PrintLog(__FUNCTION__, "mongoose::ReleaseAutoLock:%p tag->tagLock:%p begin", *ppInstance, (*ppInstance)->tagLock);
            IAutoLock::ReleaseAutoLock((*ppInstance)->tagLock);
            (*ppInstance)->tagLock = 0;
            PrintLog(__FUNCTION__, "mongoose::ReleaseAutoLock:%p tag->tagLock:%p end", *ppInstance, (*ppInstance)->tagLock);
        }
        delete *ppInstance;
        *ppInstance = 0;
    }
    
    void Lock(struct IAutoLockTag ** ppInstance) {
        //PrintLog(__FUNCTION__, "mongoose::Lock:%p tag->tagLock:%p begin", *ppInstance, (*ppInstance)->tagLock);
        if ((*ppInstance)->tagLock) {
            //PrintLog(__FUNCTION__, "mongoose::Lock:%p tag->tagLock:%p Lock begin", *ppInstance, (*ppInstance)->tagLock);
            (*ppInstance)->tagLock->Lock();
            //PrintLog(__FUNCTION__, "mongoose::Lock:%p tag->tagLock:%p Lock end", *ppInstance, (*ppInstance)->tagLock);
        }
        //PrintLog(__FUNCTION__, "mongoose::Lock:%p tag->tagLock:%p end", *ppInstance, (*ppInstance)->tagLock);
    }
    void UnLock(struct IAutoLockTag ** ppInstance) {
        if ((*ppInstance)->tagLock) {
            (*ppInstance)->tagLock->Unlock();
        }
    }
    
    
#ifdef __cplusplus
};
#endif

