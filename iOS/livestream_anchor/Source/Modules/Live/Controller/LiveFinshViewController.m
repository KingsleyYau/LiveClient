//
//  LiveFinshViewController.m
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveFinshViewController.h"
#import "BookPrivateBroadcastViewController.h"

#import "RecommandCollectionViewCell.h"
#import "GetPromoAnchorListRequest.h"
#import "LSImageViewLoader.h"
#import "LiveBundle.h"
#import "LiveModule.h"
#import "AnchorPersonalViewController.h"
#import "LiveUrlHandler.h"

@interface LiveFinshViewController ()
#pragma mark - 推荐逻辑
@property (atomic, strong) NSArray *recommandItems;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) LSImageViewLoader *ladyImageLoader;
@property (nonatomic, strong) LSImageViewLoader *backgroundImageloader;

@end

@implementation LiveFinshViewController
- (void)initCustomParam {
    [super initCustomParam];
    NSLog(@"LiveFinshViewController::initCustomParam()");
}

- (void)dealloc {
    NSLog(@"LiveFinshViewController::dealloc()");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.ladyImageLoader = [LSImageViewLoader loader];
    self.backgroundImageloader = [LSImageViewLoader loader];
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)setupContainView {
    // 初始化模糊背景
//    [self setupBgImageView];
    // 更新控件数据
    [self updateControlDataSource];
}

- (void)updateControlDataSource {
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.width * 0.5f;
    self.headImageView.layer.masksToBounds = YES;
    
    self.viewHotBtn.layer.cornerRadius = 10;
    self.viewHotBtn.layer.masksToBounds = YES;
    
    [self.ladyImageLoader refreshCachedImage:self.headImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    [self.backgroundImageloader loadImageWithImageView:self.backgroundImageView options:0 imageUrl:self.liveRoom.roomPhotoUrl placeholderImage:
     nil];
}

#pragma mark - 根据错误码显示界面
- (void)handleError:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    
//    switch (errType) {
//            
//        // TOOP:1 没钱
//        case ZBLCC_ERR_NO_CREDIT:
//        case ZBLCC_ERR_COUPON_FAIL:{
//            self.recommandView.hidden = YES;
//            self.bookPrivateBtn.hidden = YES;
//            self.viewHotBtn.hidden = YES;
//            self.addCreditBtn.hidden = NO;
//            self.tipLabel.text = NSLocalizedStringFromSelf(@"WATCHING_ERR_ADD_CREDIT");
//        } break;
//            
//        // TOOP:2 退入后台60s超时
//        case LCC_ERR_BACKGROUND_TIMEOUT:{
//            self.recommandView.hidden = YES;
//            self.bookPrivateBtn.hidden = YES;
//            self.viewHotBtn.hidden = NO;
//            self.addCreditBtn.hidden = YES;
//            self.tipLabel.text = NSLocalizedStringFromSelf(@"TIMEOUT_A_MINUTE");
//        } break;
//        
//        // TOOP:3 正常关闭直播间,显示推荐主播列表
//        case ZBLCC_ERR_RECV_REGULAR_CLOSE_ROOM:{
//            [self getAdvisementList];
//            self.bookPrivateBtn.hidden = NO;
//            self.viewHotBtn.hidden = YES;
//            self.addCreditBtn.hidden = YES;
//            self.tipLabel.text = self.errMsg;
//        } break;
//        
//        // TOOP:4 被踢出直播间
//        case LCC_ERR_ROOM_LIVEKICKOFF:{
//            self.recommandView.hidden = YES;
//            self.bookPrivateBtn.hidden = YES;
//            self.viewHotBtn.hidden = NO;
//            self.addCreditBtn.hidden = YES;
//            self.tipLabel.text = self.errMsg;
//        } break;
//            
//        default:{
//            self.recommandView.hidden = YES;
//            self.bookPrivateBtn.hidden = NO;
//            self.viewHotBtn.hidden = YES;
//            self.addCreditBtn.hidden = YES;
//            self.tipLabel.text = self.errMsg;
//        } break;
//    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    
    [self handleError:self.errType errMsg:self.errMsg];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupBgImageView {
    // 设置模糊
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.backgroundImageView addSubview:visualView];
}



- (IBAction)viewHotAction:(id)sender {

    [self  dismissViewControllerAnimated:YES completion:nil];

}


@end
