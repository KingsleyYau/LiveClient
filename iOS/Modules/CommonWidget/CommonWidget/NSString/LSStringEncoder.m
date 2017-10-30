//
//  LSStringEncoder.m
//  CommonWidget
//
//  Created by Max on 2017/10/16.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSStringEncoder.h"

#import <CommonCrypto/CommonDigest.h>

@implementation LSStringEncoder
+ (NSString *)md5String:(NSString *)string {
    const char *cString = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH] = {0};
    CC_MD5(cString, (CC_LONG)strlen(cString), result);
    
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02X", result[i]];
    }
    return md5String;
}
@end
