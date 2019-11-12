//
//  LSStoreListToLadyViewController.m
//  livestream
//
//  Created by Calvin on 2019/10/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSStoreListToLadyViewController.h"
#import "LSStoreCollectionView.h"
#import "LSAddCartSuccessView.h"
#import "LSContinueNavView.h"
#import "LSStoreListHeadView.h"
#import "DialogTip.h"

#import "LSStoreFlowerGiftRequest.h"
#import "LSGetCartGiftTypeNumRequest.h"

#import "LSUserInfoManager.h"
#import "LSAddresseeOrderManager.h"

#import "LSStoreDetailViewController.h"
#import "LSCheckOutViewController.h"

@interface LSStoreListToLadyViewController ()<LSStoreCollectionViewDelegate,UIScrollViewRefreshDelegate,LSListViewControllerDelegate,CAAnimationDelegate,LSAddCartSuccessViewDelegate,LSContinueNavViewDelegate,LSStoreListHeadViewDelegate>
@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, strong) IBOutlet LSStoreCollectionView * storeView;
@property (weak, nonatomic) IBOutlet LSStoreListHeadView *headView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewH;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, strong) UIImageView * selectImage;
@property (nonatomic, strong) LSAddCartSuccessView * successTipView;
@property (nonatomic, strong) LSContinueNavView * navView;
@property (nonatomic, strong) LSBadgeButton * checkoutBtn;
@property (nonatomic, assign) NSInteger cartNum;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation LSStoreListToLadyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    
    [self.storeView.collectionView setupPullRefresh:self pullDown:YES pullUp:NO];
    self.storeView.collectionView.pullScrollEnabled = YES;
    self.storeView.collectionViewDelegate = self;
       
    self.headView.delegate = self;
    
    [self getStroeData];
    
    self.canPopWithGesture = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self getCartNumData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isAddSuccess) {
        self.isAddSuccess = NO;
        [self setTipTitleIsCheckout:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
 
    UIView * contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setImage:[UIImage imageNamed:@"Navigation_Back_Button"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn addTarget:self action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btn];
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc]initWithCustomView:contentView];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    self.navView = [[LSContinueNavView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 44, 44)];
    self.navView.delegate = self;
    self.navigationItem.titleView = self.navView;
    [self.navView setName:self.anchorName andHeadImage:self.anchorImageUrl];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self getAnchorDetail];
}

- (void)navBack {
    if ([self.navView.checkoutBtn.badgeValue integerValue] > 0) {
        [self setTipTitleIsCheckout:NO];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setTipView {
    [self.successTipView removeFromSuperview];
    self.successTipView = nil;
    self.successTipView = [[LSAddCartSuccessView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.successTipView.delegate = self;
    [self.navigationController.view addSubview:self.successTipView];
}

- (void)setTipTitleIsCheckout:(BOOL)isCheckout {
    [self setTipView];
    if (isCheckout) {
        self.successTipView.successIconW.constant = 18;
        self.successTipView.tipLabel.text = @"This item has been successfully added to your cart!";
        self.successTipView.exitBtn.hidden = YES;
        self.successTipView.continueBtn.hidden = NO;
    }else {
        self.successTipView.successIconW.constant = 0;
        self.successTipView.tipLabel.text = @"You have unfinished order, settle now?";
        self.successTipView.exitBtn.hidden = NO;
        self.successTipView.continueBtn.hidden = YES;
    }
}



#pragma mark - HeadViewDelegate
- (void)storeListHeadViewDidChooseBtn {
    
    self.headView.tableView.hidden = !self.headView.tableView.hidden;
    if (self.headViewH.constant != 44) {
        self.headViewH.constant  = 44;
        self.bgView.hidden = YES;
    }else {
        if (self.items.count < 5) {
            self.headViewH.constant  = 44 * self.items.count + 44;
        }else {
            self.headViewH.constant  = 44 * 5 + 44;
        }
        self.bgView.hidden = NO;
    }
}

- (void)storeListHeadViewSelectSection:(NSInteger)section {
    
    [self.storeView.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    [self storeListHeadViewDidChooseBtn];
}

- (IBAction)bgViewTap:(id)sender {
    
    [self storeListHeadViewDidChooseBtn];
}
#pragma mark - checkoutBtn点击方法
- (void)continueNavViewCheckoutBtnDid {
    LSCheckOutViewController *vc =  [[LSCheckOutViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = self.anchorId;
    vc.anchorName = self.anchorName;
    vc.anchorImageUrl = self.anchorImageUrl;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 数据请求接口
/**
* 获取女士资料
*/
- (void)getAnchorDetail {
    
    if (self.anchorName == nil || self.anchorImageUrl == nil) {
        [[LSUserInfoManager manager]getUserInfo:self.anchorId finishHandler:^(LSUserInfoModel *item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navView setName:item.nickName andHeadImage:item.photoUrl];
            });
        }];
    }
}

/**
* 获取列表数据
*/
 - (void)getStroeData {
     [self showLoading];
     self.isLoading = YES;
     LSStoreFlowerGiftRequest * request = [[LSStoreFlowerGiftRequest alloc]init];
     request.anchorId = self.anchorId;
     request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSStoreFlowerGiftItemObject *> *array) {
         dispatch_async(dispatch_get_main_queue(), ^{
             NSLog(@"LSStoreListViewController::getStroeData( [%@], errmsg : %@, count : %ld )", BOOL2SUCCESS(success), errmsg, (long)array.count);
             [self hideLoading];
             [self.storeView.collectionView finishLSPullDown:YES];
            
             if (success) {
                 [self.items removeAllObjects];
                  for (LSStoreFlowerGiftItemObject * data in array) {
                      if (data.giftList.count > 0) {
                          [self.items addObject:data];
                      }
                  }

                 if (self.items.count > 0) {
                      self.storeView.items = self.items;
                      self.headView.hidden = NO;
                     self.storeView.collectionView.hidden = NO;
                      self.headView.titleArray = self.items;
                      [self.headView reloadData];
                      [self.storeView reloadData];
                      //同步下拉t动画
                      [self performSelector:@selector(setLoadingSstate) withObject:nil afterDelay:0.5];
                 }else {
                     self.headView.hidden = YES;
                     self.storeView.collectionView.hidden = YES;
                     self.storeView.noDataTip.hidden = NO;
                 }
             }else {
                 self.failIcon.hidden = NO;
                 self.failIcon.image = [UIImage imageNamed:@"Home_Hot&follow_fail"];
                 self.failView.hidden = NO;
                 self.failBtn.hidden = NO;
                 self.listDelegate = self;
             }
         });
     };
     [[LSSessionRequestManager manager]sendRequest:request];
 }

- (void)setLoadingSstate {
     self.isLoading = NO;
}

/**
* 获取主播购物车礼品总数
*/
- (void)getCartNumData {
    LSGetCartGiftTypeNumRequest * request = [[LSGetCartGiftTypeNumRequest alloc]init];
    request.anchorId = self.anchorId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int num) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSStoreListViewController::getCartNumData( [%@], errmsg : %@, num : %d )", BOOL2SUCCESS(success), errmsg, num);
            if (num > 0) {
                self.navView.checkoutBtn.badgeValue = [NSString stringWithFormat:@"%d",num];
            }
            else {
                self.navView.checkoutBtn.badgeValue = nil;
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

/**
* 添加购物车
*/
- (void)addCartData:(NSString *)giftId andImageView:(UIImageView *)imageView{
    self.view.userInteractionEnabled = NO;
    [[LSAddresseeOrderManager manager] addCartGift:giftId anchorId:self.anchorId finish:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        NSLog(@"LSStoreListViewController::addCartData( [%@], errmsg : %@, giftId : %@ )", BOOL2SUCCESS(success), errmsg, giftId);
        if (success) {
            [self getCartNumData];
            
              CGRect frame = [imageView.superview convertRect:imageView.frame toView:self.view];
              
              self.selectImage =[[UIImageView alloc]initWithFrame:frame];
              self.selectImage.image = imageView.image;
              [self.view addSubview:self.selectImage];

              [self cartAnimation:frame];
        }
        else {
            self.view.userInteractionEnabled = YES;
            [self showAlertView:errmsg];

        }
    }];
}

- (void)showAlertView:(NSString *)msg {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *btnTitle = NSLocalizedString(@"OK", @"OK");
    [alertController addAction:[UIAlertAction actionWithTitle:btnTitle
      style:UIAlertActionStyleDefault
    handler:^(UIAlertAction *_Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - LSStoreCollectionViewDelegate
- (void)waterfallView:(LSStoreCollectionView *)view didSelectItem:(LSFlowerGiftItemObject *)item {
    LSStoreDetailViewController * vc = [[LSStoreDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.giftId = item.giftId;
    vc.anchorId = self.anchorId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)waterfallView:(LSStoreCollectionView *)view addCart:(NSString *)giftId forImageView:(UIImageView *)imageView{
    [self addCartData:giftId andImageView:imageView];
}

- (void)waterfallView:(LSStoreCollectionView *)view willDisplaySupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.storeView.isUpScroll && self.headView.tableView.hidden && !self.isLoading) {
        self.headView.selectRow = indexPath.section==0?0:indexPath.section - 1;
        [self.headView reloadData];
    }
}

- (void)waterfallView:(LSStoreCollectionView *)view didEndDisplayingSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath {
    if (self.storeView.isUpScroll && self.headView.tableView.hidden && !self.isLoading) {
        self.headView.selectRow = indexPath.section;
        [self.headView reloadData];
    }
}

- (void)waterfallViewLoadHeadViw {
    self.headView.selectRow = 0;
    [self.headView reloadData];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self getStroeData];
}

#pragma mark - LSListViewControllerDelegate
- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
    self.failView.hidden = YES;
    [self getStroeData];
}

#pragma mark - LSAddCartSuccessViewDelegate
- (void)addCartSuccessViewDidCheckoutBtn {
    [self continueNavViewCheckoutBtnDid];
}

- (void)addCartSuccessViewDidContiuneBtn {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 购物车动画
- (void)cartAnimation:(CGRect)frame {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2)];
    [path addCurveToPoint:CGPointMake(SCREEN_WIDTH - 40, 0) controlPoint1:CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height) controlPoint2:CGPointMake(frame.origin.x, frame.origin.y - 30)];
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path.CGPath;
    
    /* 缩小 */
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:0.25]; // 结束时的倍率
    
    CABasicAnimation * animation3 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation3.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的透明度
    animation3.toValue = [NSNumber numberWithFloat:0.2]; // 结束时的透明度
    
    /* 动画组 */
    CAAnimationGroup *group = [CAAnimationGroup animation];
    
    // 动画选项设定
    group.duration = 0.4;
    group.repeatCount = 1;
    
    // 添加动画
    group.animations = [NSArray arrayWithObjects:animation,pathAnimation,animation3,nil];
    group.delegate = self; // 指定委托对象
    [self.selectImage.layer addAnimation:group forKey:@"move-rotate-layer"];
}

/**
 * 动画开始时
 */
- (void)animationDidStart:(CAAnimation *)theAnimation
{
    self.view.userInteractionEnabled = NO;
}
/**
 * 动画结束时
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    self.view.userInteractionEnabled = YES;
    [self.selectImage removeFromSuperview];
    self.selectImage = nil;
}
 
@end
