//
//  NSString+MD5HexDigest.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "NSString+MD5HexDigest.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5HexDigest)
- (NSString*)toMD5String
{
    const char *str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH] = {0};
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *code = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [code appendFormat:@"%02X", result[i]];
    }
    return code;
}
@end
