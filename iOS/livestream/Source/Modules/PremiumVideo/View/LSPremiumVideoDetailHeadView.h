//
//  LSPremiumVideoDetailHeadView.h
//  livestream
//
//  Created by Calvin on 2020/8/3.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPremiumVideoDetailItemObject.h"
#import "LSPremiumVideoinfoItemObject.h"

@protocol LSPremiumVideoDetailHeadViewDeleagte <NSObject>

- (void)premiumVideoDetailHeadViewShowSub:(BOOL)isShow;

- (void)premiumVideoDetailHeadViewDidFollowBtnDid;

- (void)premiumVideoDetailHeadViewDidRetryBtnDid;

- (void)premiumVideoDetailHeadViewDidBackBtnDid;

- (void)premiumVideoDetailHeadViewDidNextVideoBtnDid:(NSString *)videoId;
@end

@interface LSPremiumVideoDetailHeadView : UIView 

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIButton *moveBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subH;
@property (weak, nonatomic) IBOutlet UIView *freeTipView;
@property (weak, nonatomic) IBOutlet UIView *freeTipTitleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeTipTitleViewW;
@property (weak, nonatomic) id<LSPremiumVideoDetailHeadViewDeleagte> delegate;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
@property (weak, nonatomic) IBOutlet UIView *errorTipView;
@property (weak, nonatomic) IBOutlet UIView *noVideoView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIView *nextVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *nextVideoImage;
@property (weak, nonatomic) IBOutlet UILabel *nextVideoTitle;
@property (weak, nonatomic) IBOutlet UILabel *nextVideosubTitle;
@property (weak, nonatomic) IBOutlet UILabel *nextVideoTime;
@property (weak, nonatomic) IBOutlet UIButton *replayBtn;
@property (weak, nonatomic) IBOutlet UIImageView *videoCoverImage;

+ (CGFloat)getContentH:(LSPremiumVideoDetailItemObject *)item isShowSub:(BOOL)isShow;
- (void)setVideoTitle:(LSPremiumVideoDetailItemObject *)item;
- (void)setHeadViewUI:(LSPremiumVideoDetailItemObject *)item;
- (void)setNextVideoUI:(LSPremiumVideoinfoItemObject *)item;
- (void)deleteVideo;
@end

 
