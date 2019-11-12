//
//  LSStoreFlowerGiftItemObject.h
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSFlowerGiftItemObject.h"

@interface LSStoreFlowerGiftItemObject : NSObject
{

}
/**
 * 商店的鲜花礼品列表结构体
 * typeId            类型ID
 * typeName         类型名称
 * isHasGreeting    是否有免费贺卡
 * giftList         礼品列表
 */
@property (nonatomic, copy) NSString* typeId;
@property (nonatomic, copy) NSString* typeName;
@property (nonatomic, assign) BOOL isHasGreeting;
@property (nonatomic, strong) NSMutableArray<LSFlowerGiftItemObject *>* giftList;
@end
