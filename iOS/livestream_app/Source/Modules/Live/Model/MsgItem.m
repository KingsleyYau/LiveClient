//
//  MsgItem.m
//  livestream
//
//  Created by Max on 2017/5/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MsgItem.h"

@implementation MsgItem

- (id)init {
    if( self = [super init] ) {
        self.type = MsgType_Chat;
    }
    return self;
}
@end
