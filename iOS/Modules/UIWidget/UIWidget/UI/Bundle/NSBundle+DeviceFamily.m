//
//  NSBundle+DeviceFamily.m
//  UIWidget
//
//  Created by KingsleyYau on 14-1-14.
//  Copyright (c) 2014年 drcom. All rights reserved.
//

#import "NSBundle+DeviceFamily.h"

@implementation NSBundle (DeviceFamily)
- (NSArray *)loadNibNamedWithFamily:(NSString *)name owner:(id)owner options:(NSDictionary *)options {
    NSString *nameReal = name;

    if (nil == nameReal || nameReal.length == 0) {
        nameReal = NSStringFromClass([self class]);
    }

    BOOL bSupportiPad = NO;
    /*  应用是否支持iPad
     *  1:iPhone or iTouch
     *  2:iPad
     */
    NSArray *array = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIDeviceFamily"];
    for (NSNumber *deviceFamily in array) {
        if ([deviceFamily integerValue] == 2) {
            bSupportiPad = YES;
            break;
        }
    }

    if (bSupportiPad) {
        // 应用支持iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            // iPhone
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad
            nameReal = [NSString stringWithFormat:@"%@-iPad", nameReal];
        }
    }

    return [self loadNibNamed:nameReal owner:owner options:options];
}
@end
