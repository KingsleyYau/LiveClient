//
//  LogConfig.h
//  Cartoon
//
//  Created by Max on 2021/5/7.
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
    printf("%s", [logString UTF8String]);
}

#define NSLog(format, ...) \
    nslogToFile([NSString stringWithFormat:@"[%@]%s %@\n", currentTimeString(), __FUNCTION__, [NSString stringWithFormat:(format), ##__VA_ARGS__]])

#endif /* Config_h */
