//
//  LSStoreListViewController.m
//  livestream
//
//  Created by Calvin on 2019/9/29.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSStoreListViewController.h"
#import "LSStoreCollectionView.h"
#import "LSStoreFlowerGiftRequest.h"
#import "LSGetCartGiftListRequest.h"

#import "LSStoreDetailViewController.h"
#import "LSAddresseeViewController.h"
#import "LSMyCartViewController.h"

#import "DialogTip.h"
#import "LSStoreListHeadView.h"
//test
#import "LSStoreListToLadyViewController.h"
#import "LSCheckOutViewController.h"

@interface LSStoreListViewController ()<LSStoreCollectionViewDelegate,UIScrollViewRefreshDelegate,LSListViewControllerDelegate,LSAddresseeViewControllerDelegate,LSStoreListHeadViewDelegate>


@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, strong) IBOutlet LSStoreCollectionView * storeView;
@property (weak, nonatomic) IBOutlet LSStoreListHeadView *headView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewH;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *cartView;
@property (weak, nonatomic) IBOutlet UILabel *cartNumLabel;
@property (weak, nonatomic) IBOutlet UIView *cartTipView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cartTipViewW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cartViewBottom;
@property (strong) DialogTip *dialogProbationTip;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation LSStoreListViewController

- (void)dealloc {
    if (self.dialogProbationTip.isShow) {
        [self.dialogProbationTip removeShow];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    
    self.cartView.hidden = YES;
    self.cartTipViewW.constant = 0;
    
    if (IS_IPHONE_X) {
        self.cartViewBottom.constant = 40;
    }else {
        self.cartViewBottom.constant = 20;
    }
    
    [self.storeView.collectionView setupPullRefresh:self pullDown:YES pullUp:NO];
    self.storeView.collectionView.pullScrollEnabled = YES;
    self.storeView.collectionViewDelegate = self;
        
     self.headView.delegate = self;
    
    [self getStroeData];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.dialogProbationTip = [DialogTip dialogTip];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.cartTipViewW.constant = 0;
    [self getcartNumData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

//获取列表数据
- (void)getStroeData {
    [self showLoading];
    self.isLoading = YES;
    LSStoreFlowerGiftRequest * request = [[LSStoreFlowerGiftRequest alloc]init];
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

//获取购物车数量
- (void)getcartNumData {
    LSGetCartGiftListRequest * request = [[LSGetCartGiftListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int total, NSArray<LSMyCartItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSStoreListViewController::getcartNumData( [%@], errmsg : %@, total : %ld )", BOOL2SUCCESS(success), errmsg, (long)total);
            if (total > 0) {
                int num = total;
                if (num > 99) {
                    num = 99;
                }
                self.cartNumLabel.text = [NSString stringWithFormat:@"%d",num];
                self.cartView.hidden = NO;
                self.cartTipView.hidden = NO;
                
                 [UIView animateWithDuration:0.3 animations:^{
                                        self.cartTipViewW.constant = 159;
                                        [self.view layoutIfNeeded];
                                    }completion:nil];
        
            }
            else {
                self.cartView.hidden = YES;
                self.cartTipView.hidden = YES;
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

- (void)setLoadingSstate {
     self.isLoading = NO;
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

#pragma mark - 购物车按钮点击
- (IBAction)cartViewTap:(id)sender {
    LSMyCartViewController * vc = [[LSMyCartViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - LSStoreCollectionViewDelegate
- (void)waterfallView:(LSStoreCollectionView *)view didSelectItem:(LSFlowerGiftItemObject *)item {
    LSStoreDetailViewController * vc = [[LSStoreDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.giftId = item.giftId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)waterfallView:(LSStoreCollectionView *)view addCart:(NSString *)giftId forImageView:(UIImageView *)imageView{

    LSAddresseeViewController * vc = [[LSAddresseeViewController alloc]initWithNibName:nil bundle:nil];
    vc.view.frame =  self.view.bounds;
    vc.giftID = giftId;
    vc.delegate = self;
    vc.superVC = self;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
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
#pragma mark - LSAddresseeViewControllerDelegate
- (void)addCarGiftSuccess:(LSAddresseeViewController *)controller item:(LSAddresseeItem *)item {
    [controller removeFromeView];
    LSStoreListToLadyViewController *vc = [[LSStoreListToLadyViewController alloc]initWithNibName:nil bundle:nil];
    vc.anchorId = item.anchorId;
    vc.anchorName = item.anchorName;
    vc.anchorImageUrl = item.anchorHeadUrl;
    vc.isAddSuccess = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)checkoutTopage:(LSAddresseeViewController *)controller item:(LSAddresseeItem *)item errmsg:(NSString *)errmsg isDialog:(BOOL)isDialog {
    if (isDialog) {
        [controller removeFromeView];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:errmsg preferredStyle:UIAlertControllerStyleAlert];
            
            NSString *btnTitle = NSLocalizedString(@"OK", @"OK");
            [alertController addAction:[UIAlertAction actionWithTitle:btnTitle
              style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *_Nonnull action) {
                
            }]];
            
        //    if (isFull) {
        //        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"CHECKOUT")
        //          style:UIAlertActionStyleDefault
        //        handler:^(UIAlertAction *_Nonnull action) {
        //            if (item.anchorId.length > 0) {
        //                LSCheckOutViewController *vc = [[LSCheckOutViewController alloc] initWithNibName:nil bundle:nil];
        //                vc.anchorId = item.anchorId;
        //                vc.anchorName = item.anchorName;
        //                [self.navigationController pushViewController:vc animated:YES];
        //            }
        //        }]];
        //    }
            [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self.dialogProbationTip showDialogTip:self.view tipText:errmsg];
    }
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
    [self getcartNumData];
}
@end
