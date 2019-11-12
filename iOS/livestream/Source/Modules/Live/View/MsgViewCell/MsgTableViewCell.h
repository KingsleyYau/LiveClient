//
//  MsgTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgItem.h"
#import "RoomStyleItem.h"

@class MsgTableViewCell;
@protocol MsgTableViewCellDelegate <NSObject>

- (void)msgCellRequestHttp:(NSString *)linkUrl;

@end

@interface MsgTableViewCell : UITableViewCell

@property (nonatomic, strong) YYLabel *messageLabel;

@property (nonatomic, assign) CGFloat tableViewWidth;
@property (nonatomic, assign) CGFloat messageLabelWidth;
@property (nonatomic, assign) CGFloat messageLabelHeight;

/** 代理 */
@property (nonatomic, weak) id<MsgTableViewCellDelegate> msgDelegate;


+ (NSString *)cellIdentifier;

- (void)updataChatMessage:(MsgItem *)item styleItem:(RoomStyleItem *)styleItem;

/** 新私密直播间用 */
- (void)setupChatMessage:(MsgItem *)item styleItem:(RoomStyleItem *)styleItem;

@end
