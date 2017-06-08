//
//  NSString+UrlCode.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "NSString+UrlCode.h"

@implementation NSString (UrlCode)
- (NSString*)UrlDecode
{
    NSString *decode = [[self stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return decode;
}

- (NSString*)UrlEncode
{
    NSString *result = (NSString *)
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            NULL,
                                            CFSTR("!*'();:@&=+$,/?%#[] "),
                                            kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}
@end
