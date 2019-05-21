//
//  LSSayHiAllListItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * All列表
 * sayHiId          sayHi的ID
 * anchorId         主播ID
 * nickName         主播昵称
 * cover            主播封面
 * avatar           主播头像
 * age              主播年龄
 * sendTime         发送时间戳（1970年起的秒数）
 * content          回复内容的摘要（可无，没有回复则为无或空）
 * responseNum      回复数
 * unreadNum        未读数
 * isFree           是否免费（YES：是，NO：否）
 */
@interface LSSayHiAllListItemObject : NSObject
@property (nonatomic, copy) NSString *sayHiId;
@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) NSInteger sendTime;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) int responseNum;
@property (nonatomic, assign) int unreadNum;
@property (nonatomic, assign) BOOL isFree;

@end
