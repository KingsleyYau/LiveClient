//
//  PublicViewController.m
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PublicViewController.h"
#import "AudienceCell.h"
#import "IMManager.h"
#import "LiveModule.h"
#import "RemberLiveRoomModel.h"

@interface PublicViewController ()

// 观众数组
@property(nonatomic, strong) NSMutableArray *audienceArray;

// IM管理器
@property (nonatomic, strong) IMManager *imManager;

@property (nonatomic ,strong) NSTimer * hidenTimer;

@property (nonatomic, assign) BOOL isTipShow;

@property (nonatomic, assign) BOOL isClickGot;

@property (nonatomic, strong) RemberLiveRoomModel *liveRoomModel;

@end

@implementation PublicViewController

- (void)initCustomParam {
    
    self.isTipShow = NO;
    
    self.liveRoomModel = [RemberLiveRoomModel liveRoomModel];
}

- (void)setupContainView {
    
}

- (void)dealloc {
    NSLog(@"PublicViewController::dealloc()");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    self.followAndHomepageView.layer.cornerRadius = 12;
    self.numShaowView.layer.cornerRadius = 12;
    
    self.playVC = [[PlayViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.playVC];
    self.playVC.liveRoom = self.liveRoom;
    
    [self.view addSubview:self.playVC.view];
    [self.playVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleBackGroundView.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.playVC.liveVC theSuviewToFrontWithView:self.view];
    [self.view bringSubviewToFront:self.playVC.chooseGiftListView];
    self.playVC.chooseGiftListView.top = SCREEN_HEIGHT;
    
    self.playVC.randomGiftBtnWidth.constant = self.playVC.talentBtnWidth.constant = 0;
    self.playVC.randomGiftBtnLeading.constant = self.playVC.talenBtnLeading.constant = 0;
    
    // 提示view测试
    self.tipView = [[ChardTipView alloc] init];
    [self.tipView setTipWithRoomPrice:0 roomTip:NSLocalizedStringFromSelf(@"Public_Tip") creditText:nil];
//    [self.tipView hiddenChardTip];
    [self.view addSubview:self.tipView];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chargeTipImageView.mas_bottom).offset(2);
        make.width.equalTo(@(self.chargeTipImageView.width));
        make.left.equalTo(@18);
    }];
    
    // 图片点击事件
    WeakObject(self, weakSelf);
    [self.chargeTipImageView addTapBlock:^(id obj) {
        
        if (!weakSelf.isTipShow) {
            weakSelf.hidenTimer =  [NSTimer scheduledTimerWithTimeInterval:3.0 target:weakSelf selector:@selector(hidenChardTip)
                                                              userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:weakSelf.hidenTimer forMode:NSRunLoopCommonModes];
            [weakSelf.view bringSubviewToFront:weakSelf.tipView];
            weakSelf.tipView.hidden = NO;
            weakSelf.isTipShow = YES;
        }
    }];
    
    [self text];
    
    [self.playVC.liveVC showPreview];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)viewDidDisappear:(BOOL)animated {

}

- (void)hidenChardTip {
    self.tipView.hidden = YES;
    if (self.hidenTimer) {
        [self.hidenTimer invalidate];
        self.hidenTimer = nil;
    }
    self.isTipShow = NO;
}

#pragma mark - 按钮事件
- (IBAction)pushLiveHomePage:(id)sender {
    
}

- (IBAction)followLiverAction:(id)sender {
    self.followBtnWidth.constant = 0;
    [self.playVC.liveVC addAudienceFollowLiverMessage:self.playVC.loginManager.loginItem.nickName];
}

- (IBAction)closeLiveRoom:(id)sender {
    [self sendExitRequest];
//    [self.navigationController popViewControllerAnimated:YES];
    UIViewController *vc = [[LiveModule module] moduleViewController];
    [self.navigationController popToViewController:vc animated:YES];
}

#pragma mark - 请求数据逻辑
- (void)sendExitRequest {
    NSLog(@"PublicViewController::sendExitRequest( [发送粉丝退出直播间请求], roomId : %@ )", self.liveRoom.roomId);
}

// 3.1 观众进入直播间
- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl videoUrls:(NSArray<NSString*>* _Nonnull)videoUrls roomType:(RoomType)roomType credit:(double)credit usedVoucher:(BOOL)usedVoucher fansNum:(int)fansNum emoTypeList:(NSArray<NSNumber *>* _Nonnull)emoTypeList loveLevel:(int)loveLevel rebateInfo:(RebateInfoObject* _Nonnull)rebateInfo favorite:(BOOL)favorite leftSeconds:(int)leftSeconds waitStart:(BOOL)waitStart manPushUrl:(NSArray<NSString*>* _Nonnull)manPushUrl manLevel:(int)manLevel roomPrice:(double)roomPrice manPushPrice:(double)manPushPrice manFansiNum:(int)manFansiNum{
    
    self.tipView = [[ChardTipView alloc] init];
    [self.tipView setTipWithRoomPrice:roomPrice roomTip:NSLocalizedStringFromSelf(@"Public_Tip") creditText:nil];
    
    // 判断是否是第一次进直播间
    if ([self.liveRoomModel getToRoomtyprPrice:roomType]) {
        [self.tipView hiddenChardTip];
        
    } else {
        [self.liveRoomModel fristComeIntheLiveRoom:roomType price:roomPrice];
    }
    [self.view addSubview:self.tipView];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chargeTipImageView.mas_bottom).offset(2);
        make.left.right.equalTo(self.chargeTipImageView);
    }];
}


- (void)text{
    
    UIImage *image1 = [UIImage imageNamed:@"freeLive_nomal_background"];
    UIImage *image2 = [UIImage imageNamed:@"freeLive_ invite_btn"];
    UIImage *image3 = [UIImage imageNamed:@"Login_Main_Logo"];
    UIImage *image4 = [UIImage imageNamed:@"freeLive_nomal_background"];
    UIImage *image5 = [UIImage imageNamed:@"freeLive_ invite_btn"];
    UIImage *image6 = [UIImage imageNamed:@"Login_Main_Logo"];
    UIImage *image7 = [UIImage imageNamed:@"freeLive_ invite_btn"];
    UIImage *image8 = [UIImage imageNamed:@"Login_Main_Logo"];
    UIImage *image9 = [UIImage imageNamed:@"freeLive_nomal_background"];
    UIImage *image10 = [UIImage imageNamed:@"Login_Main_Logo"];
    UIImage *image11 = [UIImage imageNamed:@"freeLive_ invite_btn"];
    UIImage *image12 = [UIImage imageNamed:@"freeLive_nomal_background"];
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:image1,image2,image3,image4,image5,image6,image7,image8,image9,image10,image11,image12, nil];
    self.audienceArray = array;
    [self.audienceView updateAudienceViewWithAudienceArray:self.audienceArray];
}


@end
