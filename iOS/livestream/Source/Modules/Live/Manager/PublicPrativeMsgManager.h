//
//  PublicPrativeMsgManager.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LiveRoomMsgManager.h"

@interface PublicPrativeMsgManager : LiveRoomMsgManager

- (NSMutableAttributedString *)setupChatMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item;

- (NSMutableAttributedString *)setupGiftMessageStyle:(RoomStyleItem *)roomStyleItem msgItem:(MsgItem *)item;

@end
