//
//  LSMailPrivatePlayView.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/13.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailAttachmentModel.h"

@class LSMailPrivatePlayView;
@protocol LSMailPrivatePlayViewDelegate <NSObject>
@optional
- (void)mailPrivatePlayView:(LSMailPrivatePlayView *)view playByStamp:(LSMailAttachmentModel *)model;
- (void)mailPrivatePlayView:(LSMailPrivatePlayView *)view playByCredits:(LSMailAttachmentModel *)model;
- (void)mailPrivatePlayView:(LSMailPrivatePlayView *)view unlockPlayVideo:(LSMailAttachmentModel *)model;
@end

@interface LSMailPrivatePlayView : UIView

@property (weak, nonatomic) IBOutlet UIView *videoPlayView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activiView;
@property (weak, nonatomic) IBOutlet UIView *buyVideoView;
@property (weak, nonatomic) IBOutlet UILabel *buyVideoTipLabel;

@property (weak, nonatomic) IBOutlet UIButton *stampsBuyBtn;
@property (weak, nonatomic) IBOutlet UIButton *creditsBuyBtn;

@property (weak, nonatomic) IBOutlet UIView *unlockPlayView;

@property (weak, nonatomic) IBOutlet UIView *expiredView;

@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteLabelTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteLabelBottom;

@property (weak, nonatomic) IBOutlet UILabel *representLabel;

@property (nonatomic, weak) id<LSMailPrivatePlayViewDelegate> delegate;

@property (nonatomic, strong) LSMailAttachmentModel *item;

- (void)hideenAllView;
- (void)showBuyVideoView;
- (void)showUnlockPlayView;
- (void)showExpiredView;

- (void)activiViewIsShow:(BOOL)isShow;

@end
