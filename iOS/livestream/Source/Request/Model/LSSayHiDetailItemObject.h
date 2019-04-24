//
//  LSSayHiDetailItemObject.h
//  dating
//
//  Created by Alex on 19/4/18.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * sayHi详情
 * sayHiId          sayHi的ID
 * anchorId         主播ID
 * nickName         主播昵称
 * cover            主播封面
 * avatar           主播头像
 * age              主播年龄
 * sendTime         发送时间戳
 * text             文本内容
 * img              图片地址
 * responseNum      回复数
 * unreadNum        未读数
 */
@interface LSSayHiDetailItemObject : NSObject
@property (nonatomic, copy) NSString *sayHiId;
@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) NSInteger sendTime;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, assign) int responseNum;
@property (nonatomic, assign) int unreadNum;

@end
