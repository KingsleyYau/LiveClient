//
//  LSMyCartItemObject.h
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSFlowerGiftBaseInfoItemObject.h"
#import "LSRecipientAnchorItemObject.h"

@interface LSMyCartItemObject : NSObject
{

}
/**
 * My cart结构体
 * anchorItem                   主播item
 * giftList                     产品列表
 */
@property (nonatomic, strong) LSRecipientAnchorItemObject* anchorItem;
@property (nonatomic, strong) NSMutableArray<LSFlowerGiftBaseInfoItemObject *>* giftList;

@end
