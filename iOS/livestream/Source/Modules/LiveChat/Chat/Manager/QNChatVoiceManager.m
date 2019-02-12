//
//  ChatVoiceManager.m
//  dating
//
//  Created by Calvin on 17/5/2.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "QNChatVoiceManager.h"

#define ChatVoiceReadHistoryFile @"LSChatVoiceRead.plist"

@implementation QNChatVoiceManager
- (instancetype)init {
    self = [super init];
    if (self) {
        [self createPlist];
    }
    return self;
}

- (void)createPlist {
    //获取完整路径
    NSString *path = [[LSFileCacheManager manager]voiceReadWithFileName:ChatVoiceReadHistoryFile];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSMutableDictionary *dictplist = [[NSMutableDictionary alloc] init];
        //写入文件
        [dictplist writeToFile:path atomically:YES];
    }
}

- (void)saveVoiceReadMessage:(NSString *)voiceId {
    NSString *path =[[LSFileCacheManager manager]voiceReadWithFileName:ChatVoiceReadHistoryFile];
    NSMutableDictionary *applist = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] mutableCopy];
    [applist setObject:@"Read" forKey:voiceId];
    [applist writeToFile:path atomically:YES];
}

- (BOOL)voiceMessageIsRead:(NSString *)voiceId {
    BOOL result = NO;
    NSString *path = [[LSFileCacheManager manager]voiceReadWithFileName:ChatVoiceReadHistoryFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSMutableDictionary *applist = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] mutableCopy];
        NSString *msgId = [applist objectForKey:voiceId];
        if (msgId.length > 0) {
            result = YES;
        } else {
            result = NO;
        }
    }
    return result;
}

- (BOOL)removeVoiceReadMessage:(NSString *)voiceId {
    BOOL result = NO;
    NSString *path = [[LSFileCacheManager manager]voiceReadWithFileName:ChatVoiceReadHistoryFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSMutableDictionary *applist = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] mutableCopy];
        NSString *msgId = [applist objectForKey:voiceId];
        if (msgId.length > 0) {
            [applist removeObjectForKey:voiceId];
            result = YES;
        }
    }
    return result;
}

@end
