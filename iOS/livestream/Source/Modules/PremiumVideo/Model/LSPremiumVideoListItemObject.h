//
//  LSPremiumVideoListItemObject.h
//  livestream
//
//  Created by Albert on 2020/8/4.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSPremiumVideoListItemObject : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString * headUrl;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *intro;

@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, assign) BOOL isCollect;
@property (nonatomic, assign) double leftCredit;
@property (nonatomic, assign) CGFloat video_total_time;
@property (nonatomic, assign) int age;

@end

NS_ASSUME_NONNULL_END
