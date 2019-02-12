//
//  LSSendMessageManager.m
//  livestream
//
//  Created by Randy_Fan on 2018/10/30.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSSendMessageManager.h"

@implementation LSSendMessageManager

- (NSString *)deleteStringALLSpace:(NSString *)str {
    NSString *string = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

- (NSString *)deleteStringHeadTailSpace:(NSString *)str {
    NSString *string = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return string;
}

- (NSString *)deleteStringLineEnter:(NSString *)str {
    // 多个或一个换行/回车替换成一个空格
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:@"\n{1,}"
                                                   options:NSRegularExpressionCaseInsensitive
                                                     error:nil];
    str = [regular stringByReplacingMatchesInString:str options:NSMatchingReportProgress  range:NSMakeRange(0, [str length]) withTemplate:@" "];
    return str;
}

@end
