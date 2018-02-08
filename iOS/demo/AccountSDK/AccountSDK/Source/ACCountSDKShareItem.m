//
//  ACCountSDKShareItem.m
//  AccountSDK
//
//  Created by Max on 2017/12/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ACCountSDKShareItem.h"

@implementation ACCountSDKShareItem
- (id)init {
    if( self = [super init] ) {
        self.type = ACCountSDKShareItemType_Link;
    }
    return self;
}
@end
