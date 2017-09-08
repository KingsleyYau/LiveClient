//
//  LiveRoomMsgManager.h
//  livestream
//
//  Created by randy on 2017/8/29.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgItem.h"
#import "SetStringItem.h"

@interface LiveRoomMsgManager : NSObject

@property (nonatomic, assign) MsgType msgType;

+ (instancetype)msgManager;

- (NSMutableAttributedString *)presentTheSetStringItem:(SetStringItem *)strItem msgItem:(MsgItem *)item;


@end
