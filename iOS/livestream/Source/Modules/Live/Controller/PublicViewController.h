//
//  PublicViewController.h
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PlayViewController.h"

#import "UITapImageView.h"
#import "YMAudienceView.h"
#import "ChardTipView.h"

#import "LiveRoom.h"

@interface PublicViewController : KKViewController

@property (nonatomic, strong) LiveRoom* liveRoom;

// 播放控制器
@property (nonatomic, strong) PlayViewController *playVC;

@property (weak, nonatomic) IBOutlet UIImageView *titleBackGroundView;

@property (weak, nonatomic) IBOutlet UITapImageView *chargeTipImageView;

@property (weak, nonatomic) IBOutlet YMAudienceView *audienceView;

@property (weak, nonatomic) IBOutlet UIView *followAndHomepageView;

@property (weak, nonatomic) IBOutlet UIView *numShaowView;

@property (weak, nonatomic) IBOutlet UIButton *homePageBtn;

@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@property (weak, nonatomic) IBOutlet UIButton *peopleNumBtn;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followBtnWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chargeTipImageWidth;

@property (strong, nonatomic) ChardTipView *tipView;


- (IBAction)pushLiveHomePage:(id)sender;

- (IBAction)followLiverAction:(id)sender;

- (IBAction)closeLiveRoom:(id)sender;


@end
