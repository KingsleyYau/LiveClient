
//
//  IMLoveLevelItemObject.h
//  livestream
//
//  Created by Max on 2018/6/11.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMLoveLevelItemObject : NSObject

/**
 * 接收直播间文本消息
 * loveLevel           亲密度等级
 * anchorId            主播ID
 * anchorName          主播昵称
 */

@property (nonatomic, assign) int loveLevel;
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull anchorName;

@end
