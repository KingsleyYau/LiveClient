//
//  LSStoreDetailViewController.m
//  livestream
//
//  Created by Calvin on 2019/10/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSStoreDetailViewController.h"
#import "LSGetFlowerGiftDetailRequest.h"
#import "LSImageViewLoader.h"
#import "LSShadowView.h"
#import "LSAddresseeViewController.h"
#import "LSStoreListToLadyViewController.h"
#import "LSCheckOutViewController.h"
#import "LSAddresseeOrderManager.h"
#import "DialogTip.h"
@interface LSStoreDetailViewController ()<LSListViewControllerDelegate,LSAddresseeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftNameLabelH;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceLabelW;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountLabelW;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subLabelH;
@property (nonatomic, strong) LSImageViewLoader * imageViewLoader;
@property (strong) DialogTip *dialogProbationTip;
@end

@implementation LSStoreDetailViewController

- (void)dealloc {
    if (self.dialogProbationTip.isShow) {
        [self.dialogProbationTip removeShow];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromSelf(@"DETAIL_NAV_TITLE");
    
    self.imageViewLoader = [LSImageViewLoader loader];
    
    self.addBtn.layer.cornerRadius = 5;
    self.addBtn.layer.masksToBounds = YES;
    
    LSShadowView * view = [[LSShadowView alloc]init];
    [view showShadowAddView:self.addBtn];
        
    [self getDetailData];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.dialogProbationTip = [DialogTip dialogTip];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.view endEditing:YES];
}

#pragma mark - 获取详情数据
- (void)getDetailData {
    [self showLoading];
    LSGetFlowerGiftDetailRequest * request = [[LSGetFlowerGiftDetailRequest alloc]init];
    request.giftId = self.giftId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSFlowerGiftItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSStoreDetailViewController::getDetailData( [%@], errmsg : %@)", BOOL2SUCCESS(success), errmsg);
            [self hideLoading];
            if (success) {
                [self setDetailData:item];
            }else {
                self.failIcon.image = [UIImage imageNamed:@"Home_Hot&follow_fail"];
                self.failView.hidden = NO;
                self.listDelegate = self;
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}

- (void)addGiftToCart {
    [[LSAddresseeOrderManager manager] addCartGift:self.giftId anchorId:self.anchorId finish:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        if (success) {
            NSInteger count = self.navigationController.viewControllers.count;
            LSStoreListToLadyViewController *vc = [self.navigationController.viewControllers[count-2] isKindOfClass:[LSStoreListToLadyViewController class]] ? self.navigationController.viewControllers[count-2] : nil;
            if (vc) {
                vc.isAddSuccess = YES;
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showErrorAlert:errmsg];
        }
    }];
}

#pragma mark - LSListViewControllerDelegate
- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
    self.failView.hidden = YES;
    [self getDetailData];
}

#pragma mark - 点击加入购物车
- (IBAction)addBtnDid:(id)sender {
    if (self.anchorId.length > 0) {
        [self addGiftToCart];
    } else {
        LSAddresseeViewController * vc = [[LSAddresseeViewController alloc]initWithNibName:nil bundle:nil];
        vc.view.frame = self.view.bounds;
        vc.giftID = self.giftId;
        vc.delegate = self;
        vc.superVC = self;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
    }
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
        
        [self showErrorAlert:errmsg];
    } else {
        [self.dialogProbationTip showDialogTip:self.view tipText:errmsg];
    }
}

- (void)showErrorAlert:(NSString *)errmsg {
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
}

#pragma mark - 填充数据
- (void)setDetailData:(LSFlowerGiftItemObject *)item {
      
      [self setGiftTitle:item.giftName andGiftId:item.giftId];
    
      [self.imageViewLoader loadHDListImageWithImageView:self.imageView
                                                 options:0
                                                imageUrl:item.giftImg
                                        placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"]
                                           finishHandler:nil];
      
      self.discountLabel.hidden = YES;
      switch (item.priceShowType) {
          case LSPRICESHOWTYPE_WEEKDAY://平日价
          {
                self.priceLabel.text = [NSString stringWithFormat:@"%0.2f",item.giftWeekdayPrice];
          }break;
          case LSPRICESHOWTYPE_HOLIDAY://节日价
          {
              self.priceLabel.text = [NSString stringWithFormat:@"%0.2f",item.giftPrice];
          }break;
          case LSPRICESHOWTYPE_DISCOUNT://优惠价
          {
              self.priceLabel.text = [NSString stringWithFormat:@"%0.2f",item.giftDiscountPrice];
              
              self.discountLabel.hidden = NO;
              NSString * str = [NSString stringWithFormat:@"$%0.2f",item.giftWeekdayPrice];
               NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:str];
                      [attributeStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x999999) range:NSMakeRange(0, str.length)];
                      [attributeStr addAttribute:NSStrikethroughStyleAttributeName value:
              @(NSUnderlineStyleSingle) range:NSMakeRange(0, str.length)];
              self.discountLabel.attributedText = attributeStr;
              
          }break;
          default:
              break;
      }
    
    if (self.discountLabel.hidden) {
        self.priceLabelW.constant = self.addBtn.tx_x - 30;
    }else {
        CGFloat w = [self.priceLabel.text sizeWithAttributes:@{NSFontAttributeName:self.priceLabel.font}].width;
        if (w > self.addBtn.tx_x - 30) {
            self.priceLabelW.constant = self.addBtn.tx_x - 30;
        }else {
            self.priceLabelW.constant = w;
            self.discountLabelW.constant = self.addBtn.tx_x - w - 40;
        }
    }
    
    CGFloat subH = [item.giftDescription boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 40, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)  attributes:@{NSFontAttributeName:self.subLabel.font} context:nil].size.height;
    
    self.subLabelH.constant = ceil(subH) + 10;
        
    self.subLabel.text = item.giftDescription;
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.subLabel.tx_y + self.subLabel.tx_height + 10);
}
 
- (void)setGiftTitle:(NSString *)giftName andGiftId:(NSString *)giftId {
     NSString * idStr = [NSString stringWithFormat:@"(Item Code: %@)",giftId];
     NSString * nameStr = [NSString stringWithFormat:@"%@ %@",giftName,idStr];
     
     NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc]initWithString:nameStr];
     [attStr setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0x383838)} range:[nameStr rangeOfString:giftName]];
     [attStr setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0x999999)} range:[nameStr rangeOfString:idStr]];
     self.giftNameLabel.attributedText = attStr;
     
     // 计算高度
    CGRect textRect = [attStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 40, MAXFLOAT)
                              options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
     
     self.giftNameLabelH.constant = ceil(textRect.size.height)+10;
}
@end
