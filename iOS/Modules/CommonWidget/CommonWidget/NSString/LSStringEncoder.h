//
//  LSStringEncoder.m.h
//  CommonWidget
//
//  Created by Max on 2017/10/16.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSStringEncoder : NSObject
+ (NSString *)md5String:(NSString *)string;
+ (NSString *)htmlEntityDecode:(NSString *)string;
@end
