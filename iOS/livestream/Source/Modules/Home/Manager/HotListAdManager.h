//
//  HotListAdManager.h
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSWomanListAdvertRequest.h"
#import "LiveRoomInfoItemObject.h"
NS_ASSUME_NONNULL_BEGIN

@protocol HotListAdManagerDelegate <NSObject>
@optional
- (void)hotListADLoad:(LSWomanListAdItemObject *)item Success:(BOOL)success;
@end

@interface HotListAdManager : NSObject

@property (nonatomic, weak) id <HotListAdManagerDelegate> hotAdDelegate;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;

+ (instancetype)manager;
- (void)getHotListAD;
@end

NS_ASSUME_NONNULL_END
