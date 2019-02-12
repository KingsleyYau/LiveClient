//
//  LSSendMessageManager.h
//  livestream
//
//  Created by Randy_Fan on 2018/10/30.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSSendMessageManager : NSObject

/**
 删除字符串中所有空格
 
 @return 删除后字符串
 */
- (NSString *)deleteStringALLSpace:(NSString *)str;

/**
 删除字符串头尾空格

 @return 删除后字符串
 */
- (NSString *)deleteStringHeadTailSpace:(NSString *)str;

/**
 删除字符串中回车/空格

 @return 删除后字符串
 */
- (NSString *)deleteStringLineEnter:(NSString *)str;

@end
