//
//  LSAddresseeViewController.m
//  livestream
//
//  Created by Randy_Fan on 2019/10/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSAddresseeViewController.h"
#import "LSAddresseeViewCell.h"
#import "LSShadowView.h"

#define CHOOSEVIEWHEIGHT(isAddre) isAddre ? 368 : 265

#define RECOMMEND_ITEMS (self.addreArray.count * 100)

@interface LSAddresseeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>


@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIView *chooseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chooseViewHeight;

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderBtn;

@property (weak, nonatomic) IBOutlet UIView *addresseeView;
@property (weak, nonatomic) IBOutlet UIButton *addOrderBtn;
@property (weak, nonatomic) IBOutlet LSCollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *activitView;


@property (assign, nonatomic) BOOL isAddre;

@property (copy, nonatomic) NSString *selectAnchorId;

@property (strong, nonatomic) NSMutableArray<LSAddresseeItem*> *addreArray;

@property (assign, nonatomic) NSInteger currentItemIndex;

@end

@implementation LSAddresseeViewController

- (void)dealloc {
    
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.isAddre = YES;
    
    self.addreArray = [[NSMutableArray alloc] init];
    
    self.currentItemIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.collectionView.tx_width , self.collectionView.tx_height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.collectionViewLayout = layout;
    UINib *nib = [UINib nibWithNibName:[LSAddresseeViewCell cellIdentifier] bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSAddresseeViewCell cellIdentifier]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)setupContainView {
    [super setupContainView];
    
    self.chooseView.layer.cornerRadius = 5;
    self.chooseView.layer.masksToBounds = YES;
    
    self.orderBtn.layer.cornerRadius = 5;
    self.orderBtn.layer.masksToBounds = YES;
    LSShadowView *shadowView1 = [[LSShadowView alloc] init];
    [shadowView1 showShadowAddView:self.orderBtn];
    
    self.addOrderBtn.layer.cornerRadius = 5;
    self.addOrderBtn.layer.masksToBounds = YES;
    LSShadowView *shadowView2 = [[LSShadowView alloc] init];
    [shadowView2 showShadowAddView:self.addOrderBtn];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getAddressee];
}

- (void)getAddressee {
    [[LSAddresseeOrderManager manager] getAddresseeList:^(BOOL success, NSArray<LSAddresseeItem *> * _Nonnull anchorList, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.addreArray removeAllObjects];
            if (success) {
                if (anchorList.count > 0) {
                    self.activitView.hidden = YES;
                    
                    [self.addreArray addObjectsFromArray:anchorList];
                    [self reloadData];
                } else {
                    [self showErrorDialog:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT") item:nil isDialog:NO];
                }
            } else {
                [self showErrorDialog:errmsg item:nil isDialog:NO];
            }
        });
    }];
}

- (void)reloadData {
    [self.collectionView reloadData];
    
    self.currentItemIndex = RECOMMEND_ITEMS / 2;
    
    // 滚动到中间
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(RECOMMEND_ITEMS / 2) inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return RECOMMEND_ITEMS;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemIndex = (indexPath.row % self.addreArray.count) % self.addreArray.count;
    LSAddresseeItem *item = self.addreArray[itemIndex];
    LSAddresseeViewCell *cell = [LSAddresseeViewCell getUICollectionViewCell:collectionView indexPath:indexPath];
    [cell setupContent:item];
    return cell;
}

- (IBAction)closeAddresseeView:(id)sender {
    [self removeFromeView];
}

- (IBAction)backToAction:(id)sender {
    self.isAddre = !self.isAddre;
    self.searchView.hidden = self.isAddre;
    if (self.isAddre) {
        self.errorLabel.hidden = self.isAddre;
    }
    self.addresseeView.hidden = !self.isAddre;
    self.chooseViewHeight.constant = CHOOSEVIEWHEIGHT(self.isAddre);
}

- (IBAction)orderAnchorAction:(id)sender {
    [self.superVC showAndResetLoading];
    LSAddresseeItem *item = [[LSAddresseeItem alloc] init];
    if (self.isAddre) {
        NSInteger itemIndex = (self.currentItemIndex % self.addreArray.count) % self.addreArray.count;
        item = self.addreArray[itemIndex];
    } else {
        self.errorLabel.hidden = YES;
        item.anchorId = self.searchField.text;
    }
    [[LSAddresseeOrderManager manager] addCartGift:self.giftID anchorId:item.anchorId finish:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        [self.superVC hideAndResetLoading];
        if (success) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(addCarGiftSuccess:item:)]) {
                [self.delegate addCarGiftSuccess:self item:item];
            }
        } else {
            [self showAddCartError:errnum errmsg:errmsg item:item];
        }
    }];
}

- (IBAction)leftListAction:(id)sender {
    self.currentItemIndex -= 1;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentItemIndex inSection:0]
    atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (IBAction)rightListAction:(id)sender {
    self.currentItemIndex += 1;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentItemIndex inSection:0]
    atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (void)showAddCartError:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg item:(LSAddresseeItem *)item {
    switch (errnum) {
        case HTTP_LCC_ERR_NO_RECEPTION_FLOWERGIFT:
        case HTTP_LCC_ERR_NO_SUPPOSE_DELIVERY:
        case HTTP_LCC_ERR_ONLY_GREETING_CARD:
        case HTTP_LCC_ERR_ITEM_TOO_MUCH:
        case HTTP_LCC_ERR_FULL_CART:{
            [self showErrorDialog:errmsg item:item isDialog:YES];
        }break;
            
        case HTTP_LCC_ERR_FLOWERGIFT_ANCHORID_INVALID:{
            // 输入错误的主播id
            if (!self.isAddre) {
                self.errorLabel.hidden = NO;
            }
        }break;
            
        default:{
            [self showErrorDialog:errmsg item:item isDialog:NO];
        }break;
    }
}

- (void)showErrorDialog:(NSString *)errmsg item:(LSAddresseeItem *)item isDialog:(BOOL)isDialog {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(checkoutTopage:item:errmsg:isDialog:)]) {
        [self.delegate checkoutTopage:self item:item errmsg:errmsg isDialog:isDialog];
    }
}

- (void)removeFromeView {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
