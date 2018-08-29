/*
 * IAutoLockWrapper.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef _IAUTOLOCK_WRAPPER_
#define _IAUTOLOCK_WRAPPER_
struct IAutoLockTag;
#ifdef __cplusplus

extern "C" {
    
#endif
    struct IAutoLockTag *GetNewAutoLock(void);
    void ReleaseAutoLock(struct IAutoLockTag ** ppInstance);
    void Lock(struct IAutoLockTag ** ppInstance);
    void UnLock(struct IAutoLockTag ** ppInstance);
    
#ifdef __cplusplus
};
#endif
#endif
