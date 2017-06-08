//
//  NSData+MD5.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (MD5)
- (NSString*)toMD5String
{
    const char *str = [self bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH] = {0};
    CC_MD5(str, (uint32_t)[self length], result);
    NSMutableString *code = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [code appendFormat:@"%02x", result[i]];
    }
    return code;
}
@end
