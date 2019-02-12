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
#import "LSShowListWithAnchorIdRequest.h"
#import "ShowDetailViewController.h"
#import "LSAddCreditsViewController.h"
@interface LiveFinshViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
#pragma mark - 推荐逻辑
@property (atomic, strong) NSArray *recommandItems;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) LSImageViewLoader *ladyImageLoader;
@property (nonatomic, strong) LSImageViewLoader *backgroundImageloader;

@property (nonatomic, strong) LSProgramItemObject *showItem;
@end

@implementation LiveFinshViewController
- (void)initCustomParam {
    [super initCustomParam];
}

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bookPrivateBtn.hidden = !self.liveRoom.priv.isHasBookingAuth;
    self.viewHotBtn.hidden = YES;
    self.addCreditBtn.hidden = YES;
    self.recommandView.hidden = YES;
    self.ladyImageLoader = [LSImageViewLoader loader];
    self.backgroundImageloader = [LSImageViewLoader loader];
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)setupContainView {
    // 初始化模糊背景
    //    [self setupBgImageView];

    // 初始化推荐控件
    [self setupRecommandView];

    // 更新控件数据
    [self updateControlDataSource];
}

- (void)updateControlDataSource {
    self.headImageView.layer.cornerRadius = 49;
    self.headImageView.layer.masksToBounds = YES;

    [self.ladyImageLoader refreshCachedImage:self.headImageView options:SDWebImageRefreshCached imageUrl:self.liveRoom.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];

    [self.backgroundImageloader loadImageWithImageView:self.backgroundImageView
                                               options:0
                                              imageUrl:self.liveRoom.roomPhotoUrl
                                      placeholderImage:
                                          nil];

   // if (self.liveRoom.liveShowType == IMPUBLICROOMTYPE_PROGRAM) {
        self.nameLabel.hidden = NO;
        self.nameLabel.text = self.liveRoom.userName;
   // }
}

#pragma mark - 根据错误码显示界面
- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {

    if (errMsg.length == 0) {
        errMsg = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
    }
    switch (errType) {

        // TODO:1 没钱
        case LCC_ERR_NO_CREDIT:
        case LCC_ERR_COUPON_FAIL: {
            self.recommandView.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.viewHotBtn.hidden = YES;
            self.addCreditBtn.hidden = NO;
            self.tipLabel.text = NSLocalizedStringFromSelf(@"WATCHING_ERR_ADD_CREDIT");
        } break;

            // TODO:2 退入后台60s超时
        case LCC_ERR_BACKGROUND_TIMEOUT: {
            self.recommandView.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.viewHotBtn.hidden = NO;
            self.addCreditBtn.hidden = YES;
            self.tipLabel.text = NSLocalizedStringFromSelf(@"TIMEOUT_A_MINUTE");
        } break;

        // TODO:3 正常关闭直播间,显示推荐主播列表
        case LCC_ERR_RECV_REGULAR_CLOSE_ROOM: {

            if (self.liveRoom.showId.length == 0) {
                [self getAdvisementList];
                // 正常结束界面
                [self reportDidShowPage:0];
            } else {
                // 节目结束页面
                [self reportDidShowPage:1];
                [self getRecommendedShow];
            }
            self.bookPrivateBtn.hidden = !self.liveRoom.priv.isHasBookingAuth;
            self.viewHotBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
            self.tipLabel.text = self.errMsg;
        } break;

        // TODO:4 被踢出直播间
        case LCC_ERR_ROOM_LIVEKICKOFF: {
            self.recommandView.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.viewHotBtn.hidden = NO;
            self.addCreditBtn.hidden = YES;
            self.tipLabel.text = self.errMsg;
        } break;
        case LCC_ERR_PRIVTE_INVITE_AUTHORITY: {
            // 主播无立即私密邀请权限
            if (self.liveRoom.showId.length == 0) {
                [self getAdvisementList];
                // 正常结束界面
                [self reportDidShowPage:0];
            } else {
                // 节目结束页面
                [self reportDidShowPage:1];
                [self getRecommendedShow];
            }
            self.bookPrivateBtn.hidden = YES;
            self.viewHotBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
            self.tipLabel.text = self.errMsg;
        }
            break;
        default: {
            // 默认正常结束页
            [self reportDidShowPage:0];
            self.recommandView.hidden = YES;
            self.bookPrivateBtn.hidden = !self.liveRoom.priv.isHasBookingAuth;
            self.viewHotBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
            self.tipLabel.text = self.errMsg;
        } break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;

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

- (void)setupRecommandView {
    NSBundle *bundle = [LiveBundle mainBundle];
    UINib *nib = [UINib nibWithNibName:@"RecommandCollectionViewCell" bundle:bundle];
    [self.recommandCollectionView registerNib:nib forCellWithReuseIdentifier:[RecommandCollectionViewCell cellIdentifier]];
    self.recommandView.hidden = YES;
}
#pragma mark - 请求推荐节目
- (void)getRecommendedShow {
    NSLog(@"LiveFinshViewController::getRecommendedShow [请求推荐节目]");
    WeakObject(self, weakSelf);
    LSShowListWithAnchorIdRequest *request = [[LSShowListWithAnchorIdRequest alloc] init];
    request.start = 0;
    request.step = 1;
    request.anchorId = self.liveRoom.httpLiveRoom.showInfo.anchorId;
    request.sortType = SHOWRECOMMENDLISTTYPE_ENDRECOMMEND;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LSProgramItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LiveFinshViewController::getRecommendedShow [请求推荐节目] success : %@, errmsg : %@, promoNum : %lu", success ? @"成功" : @"失败", errmsg, array.count);
            if (success && array.count > 0) {
                weakSelf.showItem = [array objectAtIndex:0];
                weakSelf.showView.hidden = NO;
                [weakSelf.showView updateUI:weakSelf.showItem];
            }
        });
    };

    [self.sessionManager sendRequest:request];
}

#pragma mark - 请求推荐列表
- (void)getAdvisementList {

    NSLog(@"LiveFinshViewController::getAdvisementList [请求推荐列表]");
    WeakObject(self, weakSelf);
    // TODO:获取推荐列表
    GetPromoAnchorListRequest *request = [[GetPromoAnchorListRequest alloc] init];
    request.number = 2;
    request.type = PROMOANCHORTYPE_LIVEROOM;
    request.userId = self.liveRoom.userId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        NSLog(@"LiveFinshViewController::getAdvisementList [请求推荐列表返回] success : %@, errmsg : %@, promoNum : %lu", success ? @"成功" : @"失败", errmsg, array.count);
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 刷新推荐列表
                weakSelf.recommandItems = array;
                [weakSelf reloadRecommandView];
            });
        }
    };
    [self.sessionManager sendRequest:request];
}

- (void)reloadRecommandView {
    // TODO:刷新推荐列表
    self.recommandViewWidth.constant = [RecommandCollectionViewCell cellWidth] * self.recommandItems.count + ((self.recommandItems.count - 1) * 20);
    self.recommandView.hidden = (self.recommandItems.count > 0) ? NO : YES;
    [self.recommandCollectionView reloadData];
}

#pragma mark - 推荐逻辑
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommandItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommandCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RecommandCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    LiveRoomInfoItemObject *item = [self.recommandItems objectAtIndex:indexPath.row];

    cell.imageView.image = nil;
    [cell.imageViewLoader stop];
    [cell.imageViewLoader refreshCachedImage:cell.imageView
                                     options:SDWebImageRefreshCached
                                    imageUrl:item.photoUrl
                            placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];

    cell.nameLabel.text = item.nickName;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LiveRoomInfoItemObject *item = [self.recommandItems objectAtIndex:indexPath.row];
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:NO completion:nil];
    [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];

    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToAnchorDetail:item.userId];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

- (IBAction)cancleAction:(id)sender {
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:YES completion:nil];
}

- (IBAction)bookPrivateAction:(id)sender {
    // 跳转预约
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:NO completion:nil];
    BookPrivateBroadcastViewController *vc = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    vc.userId = self.liveRoom.userId;
    vc.userName = self.liveRoom.userName;
    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
}

- (IBAction)viewHotAction:(id)sender {
    // 回到Hot列表
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:NO completion:nil];
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHomePage:LiveUrlMainListTypeHot];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

- (IBAction)addCreditAction:(id)sender {
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:NO completion:nil];
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pushShowDetailVC:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarClickRecommendShow eventCategory:EventCategoryShowCalendar];
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:NO completion:nil];
    
    ShowDetailViewController * vc = [[ShowDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.item = self.showItem;
    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
}

@end
