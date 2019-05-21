//
//  LSSayHiResponseListItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * Waiting for your reply列表
 * sayHiId          sayHi的ID
 * responseId       回复ID
 * anchorId         主播ID
 * nickName         主播昵称
 * cover            主播封面
 * avatar           主播头像
 * age              主播年龄
 * responseTime     回复时间戳
 * content          回复内容的摘要
 * hasImg           是否有图片（YES：有，NO：无）
 * hasRead          是否已读（YES：是，NO：否）
 * isFree           是否免费（YES：是，NO：否）
 */
@interface LSSayHiResponseListItemObject : NSObject
@property (nonatomic, copy) NSString *sayHiId;
@property (nonatomic, copy) NSString *responseId;
@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) NSInteger responseTime;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL hasImg;
@property (nonatomic, assign) BOOL hasRead;
@property (nonatomic, assign) BOOL isFree;

@end
