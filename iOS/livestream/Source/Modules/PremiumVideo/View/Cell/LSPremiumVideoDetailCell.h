//
//  LSPremiumVideoDetailCell.h
//  livestream
//
//  Created by Calvin on 2020/8/5.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPremiumVideoDetailItemObject.h"

@protocol LSPremiumVideoDetailCellDelegate <NSObject>

- (void)premiumVideoDetailCellDidSendAccessKeyBtn;

- (void)premiumVideoDetailCellDidCreditsWatchVideo;

- (void)premiumVideoDetailCellDidSendReminderBtn;

- (void)premiumVideoDetailCellDidDidCheckNowBtn;

- (void)premiumVideoDetailCellDidDidWatchVideo:(NSString *)keyStr;

@end


@interface LSPremiumVideoDetailCell : UITableViewCell

@property (weak, nonatomic) id<LSPremiumVideoDetailCellDelegate>cellDelegate;

@property (weak, nonatomic) IBOutlet UIView *contentBGView;

@property (weak, nonatomic) IBOutlet UIView *notUnlockView;
@property (weak, nonatomic) IBOutlet UIView *notUnlockTipView;
@property (weak, nonatomic) IBOutlet UIButton *sendKeyBtn;
@property (weak, nonatomic) IBOutlet UIView *notUnlockCreditsTipView;
@property (weak, nonatomic) IBOutlet UIButton *watchBtn;

@property (weak, nonatomic) IBOutlet UIView *accessKeyView;
@property (weak, nonatomic) IBOutlet UIView *accessKeyTipView;
@property (weak, nonatomic) IBOutlet UIView *inputKeyView;
@property (weak, nonatomic) IBOutlet UIView *sendReminderView;
@property (weak, nonatomic) IBOutlet UIButton *sendReminderBtn;
@property (weak, nonatomic) IBOutlet UITextField *textFiled;
@property (weak, nonatomic) IBOutlet UIButton *watchKeyBtn;

@property (weak, nonatomic) IBOutlet UIView *congratsView;
@property (weak, nonatomic) IBOutlet UIButton *checkNewBtn;


+ (NSInteger)cellHeight:(LSPremiumVideoDetailItemObject *)item;
+ (NSString *)cellIdentifier;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)loadUI:(LSPremiumVideoDetailItemObject *)item;
- (void)setKeyCode:(NSString *)str;
@end

