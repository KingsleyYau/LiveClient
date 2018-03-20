//
//  GiftComboManager.h
//  livestream
//
//  Created by Max on 2017/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GiftItem.h"

@interface GiftComboManager : NSObject

- (GiftItem *_Nullable)popGift:(NSString * _Nullable)itemId;
- (void)pushGift:(GiftItem *_Nonnull)item;

- (void)removeManager;

@end
