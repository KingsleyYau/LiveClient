//
//  HangOutOpenDoorCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgItem.h"

@class HangOutOpenDoorCell;
@protocol HangOutOpenDoorCellDelegate <NSObject>
- (void)inviteHangoutAnchor:(MsgItem *)item;
- (void)agreeAnchorKnock:(MsgItem *)item;
@end

@interface HangOutOpenDoorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *backgroundColorView;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UILabel *countryLabel;

@property (weak, nonatomic) IBOutlet UIButton *hangoutBtn;

@property (weak, nonatomic) IBOutlet UIButton *openBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hangoutBtnWidth;

@property (weak, nonatomic) id<HangOutOpenDoorCellDelegate> delagate;

@property (strong, nonatomic) MsgItem *msgItem;

- (void)updataChatMessage:(MsgItem *)item;

+ (NSString *)cellIdentifier;

@end
