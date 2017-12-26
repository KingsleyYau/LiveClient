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

@interface LiveFinshViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
#pragma mark - 推荐逻辑
@property (atomic, strong) NSArray *recommandItems;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) LSImageViewLoader *imageLoader;

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
    
    self.bookPrivateBtn.hidden = NO;
    self.viewHotBtn.hidden = YES;
    self.addCreditBtn.hidden = YES;
    self.recommandView.hidden = YES;
    self.imageLoader = [LSImageViewLoader loader];
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
        
    [self.imageLoader loadImageWithImageView:self.headImageView options:0 imageUrl:self.liveRoom.photoUrl placeholderImage:
     [UIImage imageNamed:@"Live_PreLive_Img_Head_Default"]];
    
    [self.imageLoader loadImageWithImageView:self.backgroundImageView options:0 imageUrl:self.liveRoom.roomPhotoUrl placeholderImage:
     nil];
    
    self.nameLabel.text = self.liveRoom.userName;
}

#pragma mark - 根据错误码显示界面
- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg {
    
    switch (errType) {
            
        // TOOP:1 没钱
        case LCC_ERR_NO_CREDIT:
        case LCC_ERR_COUPON_FAIL:{
            self.recommandView.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.viewHotBtn.hidden = YES;
            self.addCreditBtn.hidden = NO;
            self.tipLabel.text = NSLocalizedStringFromSelf(@"WATCHING_ERR_ADD_CREDIT");
        } break;
            
        // TOOP:2 退入后台60s超时
        case LCC_ERR_BACKGROUND_TIMEOUT:{
            self.recommandView.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.viewHotBtn.hidden = NO;
            self.addCreditBtn.hidden = YES;
            self.tipLabel.text = NSLocalizedStringFromSelf(@"TIMEOUT_A_MINUTE");
        } break;
        
        // TOOP:3 正常关闭直播间,显示推荐主播列表
        case LCC_ERR_RECV_REGULAR_CLOSE_ROOM:{
            [self getAdvisementList];
            self.bookPrivateBtn.hidden = NO;
            self.viewHotBtn.hidden = YES;
            self.addCreditBtn.hidden = YES;
            self.tipLabel.text = self.errMsg;
        } break;
        
        // TOOP:4 被踢出直播间
        case LCC_ERR_ROOM_LIVEKICKOFF:{
            self.recommandView.hidden = YES;
            self.bookPrivateBtn.hidden = YES;
            self.viewHotBtn.hidden = NO;
            self.addCreditBtn.hidden = YES;
            self.tipLabel.text = self.errMsg;
        } break;
            
        default:{
            self.recommandView.hidden = YES;
            self.bookPrivateBtn.hidden = NO;
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

#pragma mark - 请求推荐列表
- (void)getAdvisementList {
    
    NSLog(@"LiveFinshViewController::getAdvisementList [请求推荐列表]");
    // TODO:获取推荐列表
    GetPromoAnchorListRequest *request = [[GetPromoAnchorListRequest alloc] init];
    request.number = 2;
    request.type = PROMOANCHORTYPE_LIVEROOM;
    request.userId = self.liveRoom.userId;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        NSLog(@"LiveFinshViewController::getAdvisementList [请求推荐列表返回] success : %@, errmsg : %@, promoNum : %lu",success ? @"成功" : @"失败", errmsg, array.count);
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 刷新推荐列表
                self.recommandItems = array;
                [self reloadRecommandView];
            });
        }
    };
    [self.sessionManager sendRequest:request];
}

- (void)reloadRecommandView {
    // TODO:刷新推荐列表
    self.recommandViewWidth.constant = [RecommandCollectionViewCell cellWidth] * self.recommandItems.count + ((self.recommandItems.count - 1) * 20);
    self.recommandView.hidden = NO;
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
    [cell.imageViewLoader loadImageWithImageView:cell.imageView
                                         options:0
                                        imageUrl:item.photoUrl
                                placeholderImage:[UIImage imageNamed:@"Live_PreLive_Img_Head_Default"]];

    cell.nameLabel.text = item.nickName;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LiveRoomInfoItemObject *item = [self.recommandItems objectAtIndex:indexPath.row];
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToLookLadyAnchorId:item.userId];
    [LiveUrlHandler shareInstance].url = url;
    
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
}

- (IBAction)cancleAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:^{

                                                  }];
}

- (IBAction)bookPrivateAction:(id)sender {
    // 跳转预约
    BookPrivateBroadcastViewController *vc = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    vc.userId = self.liveRoom.userId;
    vc.userName = self.liveRoom.userName;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)viewHotAction:(id)sender {
    // 回到Hot列表
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
}


- (IBAction)addCreditAction:(id)sender {
    [self.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
}


@end
