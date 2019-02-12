//
//  LSDevice.h
//  CommonWidget
//
//  Created by Max on 2018/1/30.
//  Copyright © 2018年 drcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
@interface LSDevice : NSObject
+ (NSString *)deviceModelName;
+ (BOOL)iPhoneXStyle;
@end
