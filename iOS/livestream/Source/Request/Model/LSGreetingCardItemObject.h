//
//  LSGreetingCardItemObject.h
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSGreetingCardItemObject : NSObject
{

}
/**
 * 免费贺卡结构体
 * giftId               礼品ID
 * giftName             礼品名称
 * giftNumber           礼品数量
 */
@property (nonatomic, copy) NSString* giftId;
@property (nonatomic, copy) NSString* giftName;
@property (nonatomic, assign) int giftNumber;

@end
