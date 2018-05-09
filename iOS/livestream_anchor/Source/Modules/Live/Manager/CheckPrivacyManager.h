//
//  CheckPrivacyManager.h
//  livestream_anchor
//
//  Created by Randy_Fan on 2018/3/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CheckPrivacyManager;
@protocol CheckPrivacyManagerDelegate <NSObject>
@optional
- (void)cancelPrivacy;
@end

@interface CheckPrivacyManager : NSObject

@property (nonatomic, weak) id<CheckPrivacyManagerDelegate> checkDelegate;

typedef void (^CheckHandler)(BOOL granted);

- (void)checkPrivacyIsOpen:(CheckHandler)handler;

@end
