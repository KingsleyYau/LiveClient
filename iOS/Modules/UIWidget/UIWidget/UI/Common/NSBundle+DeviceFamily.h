//
//  NSBundle+DeviceFamily.h
//  UIWidget
//
//  Created by KingsleyYau on 14-1-14.
//  Copyright (c) 2014年 drcom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSBundle(DeviceFamily)
- (NSArray *)loadNibNamedWithFamily:(NSString *)name owner:(id)owner options:(NSDictionary *)options;
@end
