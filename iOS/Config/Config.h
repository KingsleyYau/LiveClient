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

#ifdef DEBUG
#define NSLog(format, ...) \
printf("[ (LiveLog) %s ]%s\n", [currentTimeString() UTF8String], [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])
#else
#define NSLog(...) {}
#define printf(...) {}
#endif

#endif /* Config_h */
