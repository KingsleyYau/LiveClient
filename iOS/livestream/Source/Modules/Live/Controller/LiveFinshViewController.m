//
//  LiveFinshViewController.m
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveFinshViewController.h"

#import "BookPrivateBroadcastViewController.h"
#import "ShowDetailViewController.h"
#import "LSAddCreditsViewController.h"
#import "AnchorPersonalViewController.h"
#import "LSSendSayHiViewController.h"

#import "RecommendCollectionViewCell.h"

#import "LSImageViewLoader.h"
#import "LiveBundle.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LSRoomUserInfoManager.h"

#import "LSShowListWithAnchorIdRequest.h"
#import "GetPromoAnchorListRequest.h"
#import "GetLiveEndRecommendAnchorListRequest.h"
#import "SetFavoriteRequest.h"

#define RECOMMEND_ITEMS (self.recommandItems.count * 100)

typedef enum ButtonStatus {
    ButtonStatus_None,
    ButtonStatus_Book,
    ButtonStatus_AddCredits,
    ButtonStatus_ViewHot,
} ButtonStatus;

@interface LiveFinshViewController () <UICollectionViewDelegate, UICollectionViewDataSource, RecommendCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIButton *bookPrivateBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewHotBtn;
@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *recommandView;
@property (weak, nonatomic) IBOutlet LSCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottom;


@property (weak, nonatomic) IBOutlet ShowListView *showView;

#pragma mark - 推荐逻辑
@property (assign, nonatomic) NSInteger currentItemIndex;

@property (nonatomic, strong) NSMutableArray *recommandItems;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) LSImageViewLoader *ladyImageLoader;
@property (nonatomic, strong) LSImageViewLoader *backgroundImageloader;

@property (nonatomic, strong) LSProgramItemObject *showItem;

#pragma mark - 用户信息管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

@end

@implementation LiveFinshViewController
- (void)dealloc {
    
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.ladyImageLoader = [LSImageViewLoader loader];
    self.backgroundImageloader = [LSImageViewLoader loader];
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.recommandItems = [[NSMutableArray alloc] init];
    
    self.isShowNavBar = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bookPrivateBtn.layer.cornerRadius = self.bookPrivateBtn.tx_height / 2;
    self.bookPrivateBtn.layer.masksToBounds = YES;
    self.bookPrivateBtn.hidden = YES;
    
    self.viewHotBtn.layer.cornerRadius = self.viewHotBtn.tx_height / 2;
    self.viewHotBtn.layer.masksToBounds = YES;
    self.viewHotBtn.hidden = YES;
    
    self.addCreditBtn.layer.cornerRadius = self.addCreditBtn.tx_height / 2;
    self.addCreditBtn.layer.masksToBounds = YES;
    self.addCreditBtn.hidden = YES;
    
    self.headImageView.layer.cornerRadius = self.headImageView.tx_height / 2;
    self.headImageView.layer.masksToBounds = YES;
    
    UINib *nib = [UINib nibWithNibName:[RecommendCollectionViewCell cellIdentifier] bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[RecommendCollectionViewCell cellIdentifier]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.bottomView.hidden = YES;
}

- (void)setupContainView {
    [super setupContainView];
    // 更新控件数据
    [self updateControlDataSource];
}

- (void)updateControlDataSource {
    
    if (self.liveRoom.photoUrl.length > 0) {
        [self setupLiverHeadImageView];
    }
    if (self.liveRoom.userName.length > 0 && self.liveRoom.userId.length > 0) {
        [self setupLiverNameLabel];
    }
    
    // 请求并缓存主播信息
    [self.roomUserInfoManager getLiverInfo:self.liveRoom.userId
                            finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    // 刷新女士头像
                                    if (!(self.liveRoom.photoUrl.length > 0)) {
                                        self.liveRoom.photoUrl = item.photoUrl;
                                        [self setupLiverHeadImageView];
                                    }
                                    // 刷新女士名字
                                    if (!(self.liveRoom.userName.length > 0)) {
                                        self.liveRoom.userName = item.nickName;
                                        [self setupLiverNameLabel];
                                    }
                                });
                            }];
}

- (void)setupLiverHeadImageView {
    [self.ladyImageLoader loadImageFromCache:self.headImageView
                                     options:SDWebImageRefreshCached
                                    imageUrl:self.liveRoom.photoUrl
                            placeholderImage:LADYDEFAULTIMG
                               finishHandler:^(UIImage *image){
                               }];
}

- (void)setupLiverNameLabel {
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:self.liveRoom.userName
                                        attributes:@{
                                                NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                                NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0xffffff)}];
    
    NSMutableAttributedString *anchorId = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"(ID:%@)",self.liveRoom.userId] attributes:@{
                                                            NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                            NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0x999999)}];
    [name appendAttributedString:anchorId];
    self.nameLabel.attributedText = name;
}

- (void)hideBottomView {
    [self.bottomView removeAllSubviews];
    [self.bottomView removeConstraint:self.bottomViewBottom];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.bottomView  attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:0];
    [self.bottomView addConstraint:height];
}

#pragma mark - 根据错误码显示界面
- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {

    if (errMsg.length == 0) {
        errMsg = NSLocalizedStringFromSelf(@"SERVER_ERROR_TIP");
    }
    self.tipLabel.text = errMsg;
    
    switch (errType) {
        case LCC_ERR_NO_CREDIT:
        case LCC_ERR_COUPON_FAIL: {
            // 没钱
            [self showErrorButton:ButtonStatus_AddCredits];
            [self hideBottomView];
        } break;

        case LCC_ERR_BACKGROUND_TIMEOUT:
        case LCC_ERR_ROOM_LIVEKICKOFF: {
            // 退入后台60s超时 被踢出直播间
            [self showErrorButton:ButtonStatus_ViewHot];
            [self hideBottomView];
        } break;

        case LCC_ERR_RECV_REGULAR_CLOSE_ROOM: {
            // 正常关闭直播间,显示推荐主播列表
            if (self.liveRoom.showId.length > 0) {
                // 节目结束页面
                [self reportDidShowPage:1];
                
                [self.recommandView removeFromSuperview];
                [self.bottomView layoutIfNeeded];
                [self getRecommendedShow];
            } else {
                // 直播结束界面
                [self reportDidShowPage:0];
                
                self.showView.hidden = YES;
                [self getLiveEndRecommended];
            }
            [self showErrorButton:ButtonStatus_Book];
        } break;

        default: {
            // 默认结束页
            [self reportDidShowPage:0];
            [self showErrorButton:ButtonStatus_Book];
            [self hideBottomView];
        } break;
    }
}

- (void)showErrorButton:(ButtonStatus)Status {
    switch (Status) {
        case ButtonStatus_Book:{
//            self.bookPrivateBtn.hidden = !self.liveRoom.priv.isHasBookingAuth;
            //关闭预约按钮,隐藏按钮
            self.bookPrivateBtn.hidden = YES;
            self.viewHotBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
        }break;
            
        case ButtonStatus_AddCredits:{
            self.addCreditBtn.hidden = NO;
            self.bookPrivateBtn.hidden = YES;
            self.viewHotBtn.hidden = YES;
        }break;
            
        case ButtonStatus_ViewHot:{
            self.viewHotBtn.hidden = NO;
            self.bookPrivateBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
        }break;
            
        default:{
            self.viewHotBtn.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
        }break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.viewIsAppear) {
        [self handleError:self.errType errMsg:self.errMsg];
    }
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

#pragma mark - 请求推荐节目
- (void)getRecommendedShow {
    NSLog(@"LiveFinshViewController::getRecommendedShow [请求推荐节目]");
    LSShowListWithAnchorIdRequest *request = [[LSShowListWithAnchorIdRequest alloc] init];
    request.start = 0;
    request.step = 1;
    request.anchorId = self.liveRoom.httpLiveRoom.showInfo.anchorId;
    request.sortType = SHOWRECOMMENDLISTTYPE_ENDRECOMMEND;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LSProgramItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LiveFinshViewController::getRecommendedShow [请求推荐节目] success : %@, errmsg : %@, promoNum : %lu", success ? @"成功" : @"失败", errmsg, (unsigned long)array.count);
            if (success && array.count > 0) {
                self.bottomView.hidden = NO;
                
                self.showItem = [array objectAtIndex:0];
                self.showView.hidden = NO;
                [self.showView updateUI:self.showItem];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 请求推荐列表
- (void)getLiveEndRecommended {
    NSLog(@"LiveFinshViewController::getLiveEndRecommended [请求推荐列表]");
    GetLiveEndRecommendAnchorListRequest *request = [[GetLiveEndRecommendAnchorListRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSRecommendAnchorItemObject *> *array) {
        NSLog(@"LiveFinshViewController::getLiveEndRecommended( [请求直播结束页推荐主播] success : %@, errnum : %d, errmsg : %@, anchorList : %lu )",BOOL2SUCCESS(success), errnum, errmsg, (unsigned long)array.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                if (array.count > 0) {
                    self.bottomView.hidden = NO;
                    
                    [self.recommandItems removeAllObjects];
                    for (int index = 0; index < array.count; index++) {
                        LSRecommendAnchorItemObject *obj = array[index];
                        // 过滤自己
                        if (![obj.anchorId isEqualToString:self.liveRoom.userId]) {
                            [self.recommandItems addObject:array[index]];
                        }
                        if (self.recommandItems.count == 6) {
                            break;
                        }
                    }
                    if (self.recommandItems.count % 2) {
                        LSRecommendAnchorItemObject *item = [[LSRecommendAnchorItemObject alloc] init];
                        [self.recommandItems addObject:item];
                    }
                    [self reloadData];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)reloadData {
    [self.collectionView reloadData];
    
    self.currentItemIndex = RECOMMEND_ITEMS / 2;
    
    // 滚动到中间
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(RECOMMEND_ITEMS / 2) inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

#pragma maek - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return RECOMMEND_ITEMS;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemIndex = (indexPath.row % self.recommandItems.count) % self.recommandItems.count;
    LSRecommendAnchorItemObject *item = self.recommandItems[itemIndex];
    RecommendCollectionViewCell *cell = [RecommendCollectionViewCell getUICollectionViewCell:collectionView indexPath:indexPath];
    cell.delegate = self;
    [cell updataReommendCell:item];
    
    NSLog(@"cellForItem--AnchorId : %@, itemIndex : %ld",item.anchorId, (long)itemIndex);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemIndex = (indexPath.row % self.recommandItems.count) % self.recommandItems.count;
    LSRecommendAnchorItemObject *item = self.recommandItems[itemIndex];
    if (item.anchorId.length > 0) {
        AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
        listViewController.anchorId = item.anchorId;
        listViewController.enterRoom = 0;
        [self.navigationController pushViewController:listViewController animated:YES];
    }
}

#pragma mark - RecommendCollectionViewCellDelegate
- (void)recommendViewCellFollowToAnchor:(LSRecommendAnchorItemObject *)item {
    if (item.anchorId.length > 0) {
        SetFavoriteRequest *request = [[SetFavoriteRequest alloc] init];
        request.userId = item.anchorId;
        request.isFav = YES;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
            NSLog(@"LiveFinshViewController::SetFavoriteRequest( [关注主播 success : %@] )",BOOL2SUCCESS(success));
        };
        [self.sessionManager sendRequest:request];
    }
}

- (void)recommendViewCellSayHiToAnchor:(LSRecommendAnchorItemObject *)item {
    if (item.anchorId.length > 0) {
        LSSendSayHiViewController *vc = [[LSSendSayHiViewController alloc] initWithNibName:nil bundle:nil];
        vc.anchorId = item.anchorId;
        vc.anchorName = item.anchorNickName;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Action
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
    NSURL *url = [[LiveUrlHandler shareInstance] createBuyCredit];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (IBAction)pushShowDetailVC:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarClickRecommendShow eventCategory:EventCategoryShowCalendar];
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:NO completion:nil];
    
    ShowDetailViewController * vc = [[ShowDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.item = self.showItem;
    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
}

- (IBAction)lastRecommendAction:(id)sender {
    self.currentItemIndex -= 2;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentItemIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (IBAction)nextRecommendAction:(id)sender {
    self.currentItemIndex += 2;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentItemIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

@end
