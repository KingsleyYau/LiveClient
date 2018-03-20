//
//  Config.h
//  livestream
//
//  Created by Max on 2017/10/24.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef Config_h
#define Config_h

inline static NSString *currentTimeString() {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *string = [formatter stringFromDate:[NSDate date]];
    return string;
}

inline static void nslogToFile(NSString *logString) {
    NSString *str = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger count = [numberRegular numberOfMatchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];
    
    // 根据版本号是否带字母判断打印log
    if (count) {
        // add by Samson 2018-01-16, 改为在nslogToFile中打印log到Output
        printf("[ (LiveLog) %s ]%s\n", [currentTimeString() UTF8String], [logString UTF8String]);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *logDir = [NSString stringWithFormat:@"%@/log", cacheDir];
        NSString *fileName = [NSString stringWithFormat:@"%@/NSLog-%@.log", logDir, dateString];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:nil];
        if(![fileManager fileExistsAtPath:fileName]) {
            [logString writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
        } else {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
            [fileHandle seekToEndOfFile];
            NSData *data = [logString dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle writeData:data];
            [fileHandle closeFile];
        }
    }
}

// modify by Samson 2018-01-16, 改为不判断release版才打印log，由nslogToFile()判断是否打log
//#ifdef DEBUG
//#define NSLog(format, ...) \
//printf("[ (LiveLog) %s ]%s\n", [currentTimeString() UTF8String], [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String]); \
//nslogToFile([NSString stringWithFormat:@"[ (LiveLog) %@ ]%@\n", currentTimeString(), [NSString stringWithFormat:(format), ##__VA_ARGS__]])
#define NSLog(format, ...) \
nslogToFile([NSString stringWithFormat:@"[ (LiveLog) %@ ]%@\n", currentTimeString(), [NSString stringWithFormat:(format), ##__VA_ARGS__]])
//#else
//#define NSLog(...) {}
//#define printf(...) {}
//#endif

#endif /* Config_h */
