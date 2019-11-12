//
//  PraviteLiveMsgManager.h
//  livestream
//
//  Created by Randy_Fan on 2019/8/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveRoomMsgManager.h"

@interface PraviteLiveMsgManager : LiveRoomMsgManager

- (NSMutableAttributedString *)setupChatMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item;

- (NSMutableAttributedString *)setupGiftMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item;

@end

