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
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString;
+ (NSString *)textPreDetail;

- (void)setTextBackgroundViewColor:(RoomStyleItem *)item;

- (void)changeMessageLabelWidth:(CGFloat)width;

- (void)updataChatMessage:(MsgItem *)item;

@end
