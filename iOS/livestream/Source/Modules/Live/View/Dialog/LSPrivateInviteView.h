//
//  LSPrivateInviteView.h
//  livestream
//
//  Created by test on 2019/6/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateInviteItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSPrivateInviteView : UIView
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *anchorIcon;
@property (weak, nonatomic) IBOutlet UILabel *inviteMsg;
@property (weak, nonatomic) IBOutlet UIButton *startOneOnOneBtn;
@property (weak, nonatomic) IBOutlet UIImageView *freeIcon;
@property (weak, nonatomic) IBOutlet UIButton *declineBtn;

@property (nonatomic, strong) PrivateInviteItem *item;
+ (instancetype)initPrivateInviteView;
- (void)showPrivateViewInView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
