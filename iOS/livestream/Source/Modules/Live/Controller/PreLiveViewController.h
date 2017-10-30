//
//  PreLiveViewController.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

#import "LiveRoom.h"

@interface PreLiveViewController : LSGoogleAnalyticsViewController
#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;

#pragma mark - 界面
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *ladyImageView;
@property (nonatomic, weak) IBOutlet UILabel* statusLabel;
@property (nonatomic, weak) IBOutlet UILabel* handleCountDownLabel;
@property (nonatomic, weak) IBOutlet UILabel* ladyNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* tipsLabel;
@property (nonatomic, weak) IBOutlet UILabel* countDownLabel;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;

@property (nonatomic, weak) IBOutlet UIButton *retryButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *retryButtonHeight;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *startButtonTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *startButtonHeight;
@property (nonatomic, weak) IBOutlet UIButton *bookButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bookButtonTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bookButtonHeight;
@property (nonatomic, weak) IBOutlet UIButton *inviteButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inviteButtonTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inviteButtonHeight;
@property (nonatomic, weak) IBOutlet UIButton *addCreditButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *addCreditButtonTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *addCreditButtonHeight;
@property (nonatomic, weak) IBOutlet UIButton *viewProfileButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *viewProfileButtonTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *viewProfileButtonHeight;
@property (nonatomic, weak) IBOutlet UIButton *viewBoardcastButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *viewBoardcastButtonTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *viewBoardcastButtonHeight;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *recommandViewWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *recommandViewHeight;
@property (nonatomic, weak) IBOutlet UIView *recommandView;
@property (nonatomic, weak) IBOutlet UICollectionView *recommandCollectionView;

@end
