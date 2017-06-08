//
//  GiftItem.h
//  livestream
//
//  Created by Max on 2017/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftItem : NSObject

@property (strong, readonly) NSString* itemId;
@property (strong) NSString* userId;
@property (strong) NSString* userUrl;
@property (strong) NSString* userName;
@property (strong) NSString* giftId;
@property (strong) NSString* giftName;
@property (assign) NSInteger start;
@property (assign) NSInteger end;

@end
