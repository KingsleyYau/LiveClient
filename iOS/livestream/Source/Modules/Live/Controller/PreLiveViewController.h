//
//  PreLiveViewController.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

#import "LiveRoom.h"

@interface PreLiveViewController : KKViewController
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
@property (nonatomic, weak) IBOutlet UIButton *bookButton;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recommandViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recommandViewHeight;
@property (nonatomic, weak) IBOutlet UIView *recommandView;
@property (nonatomic, weak) IBOutlet UICollectionView *recommandCollectionView;

#pragma mark - 界面事件
- (IBAction)close:(id)sender;
- (IBAction)retry:(id)sender;
- (IBAction)book:(id)sender;

@end
