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
#import "LSLoginManager.h"
#import "LiveGobalManager.h"
#import "UserInfoManager.h"

@interface LiveFinshViewController ()
#pragma mark - 推荐逻辑
@property (nonatomic, strong) LSImageViewLoader *ladyImageLoader;
@property (nonatomic, strong) LSImageViewLoader *backgroundImageloader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageTop;

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
    
    if (self.liveRoom.userId.length) {
        WeakObject(self, weakSelf);
        [[UserInfoManager manager] getFansBaseInfo:self.liveRoom.userId finishHandler:^(AudienModel * _Nonnull item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.liveRoom.photoUrl = item.photoUrl;
                [weakSelf.ladyImageLoader refreshCachedImage:weakSelf.headImageView options:SDWebImageRefreshCached imageUrl:item.photoUrl
                    placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
            });
        }];
        
    } else {
        [self.ladyImageLoader refreshCachedImage:self.headImageView options:SDWebImageRefreshCached imageUrl:[LSLoginManager manager].loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
    }
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
    self.tipLabel.text = errMsg;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    
    [self handleError:self.errType errMsg:self.errMsg];
    
    if ([LSDevice iPhoneXStyle]) {
        self.headImageTop.constant = 125;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [LiveGobalManager manager].liveRoom = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (IBAction)viewHotAction:(id)sender {
//    [self.view removeFromSuperview];
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:^{
                                                      
                                                  }];
}


@end
