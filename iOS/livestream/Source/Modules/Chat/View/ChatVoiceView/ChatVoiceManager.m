//
//  ChatVoiceManager.m
//  dating
//
//  Created by Calvin on 17/5/2.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ChatVoiceManager.h"

@implementation ChatVoiceManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createPlist];
    }
    return self;
}

- (void)createPlist
{
    //获取路径对象
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //获取完整路径
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"ChatVoiceRead.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSMutableDictionary *dictplist = [[NSMutableDictionary alloc ] init];
        //写入文件
        [dictplist writeToFile:plistPath atomically:YES];
    }
}

- (void)saveVoiceReadMessage:(NSString *)voiceId
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"ChatVoiceRead.plist"];
    NSMutableDictionary *applist = [[[NSMutableDictionary alloc]initWithContentsOfFile:path]mutableCopy];
    [applist setObject:@"Read" forKey:voiceId];
    [applist writeToFile:path atomically:YES];
}

- (BOOL)voiceMessageIsRead:(NSString *)voiceId
{
    BOOL result = NO;
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"ChatVoiceRead.plist"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSMutableDictionary *applist = [[[NSMutableDictionary alloc]initWithContentsOfFile:path]mutableCopy];
        NSString * msgId = [applist objectForKey:voiceId];
        if (msgId.length > 0) {
            result = YES;
        }
        else
        {
            result = NO;
        }
    }
    return result;
}

- (BOOL)removeVoiceReadMessage:(NSString *)voiceId
{
    BOOL result = NO;
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"ChatVoiceRead.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSMutableDictionary *applist = [[[NSMutableDictionary alloc]initWithContentsOfFile:path]mutableCopy];
        NSString * msgId = [applist objectForKey:voiceId];
        if (msgId.length > 0) {
            [applist removeObjectForKey:voiceId];
            result = YES;
        }
    }
    return result;
}

@end
