/*
 * KLog.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef _KLOG_WRAPPER_
#define _KLOG_WRAPPER_

#ifdef __cplusplus

extern "C" {
    
#endif
    void PrintLog(const char* func, const char *fmt, ...);
    
#ifdef __cplusplus
};
#endif
#endif
