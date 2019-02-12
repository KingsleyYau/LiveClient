//
//  ManInterestItem.h
//  dating
//
//  Created by test on 2017/5/5.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSManInterestItem : NSObject

/** icon */
@property (nonatomic, strong) NSString* icon;
/** title */
@property (nonatomic, strong) NSString* title;


- (instancetype)initWithDict:(NSDictionary *)dict;

@end
