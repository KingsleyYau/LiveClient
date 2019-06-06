//
//  LSFriendsInfoItemObject.h
//  dating
//
//  Created by Alex on 18/1/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
/**
 * 好友信息
 * anchorId         主播ID
 * nickName         主播昵称
 * anchorImg        主播头像url
 * coverImg         直播间封面图url
 */
@interface LSFriendsInfoItemObject : NSObject
@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *anchorImg;
@property (nonatomic, copy) NSString *coverImg;

@end
