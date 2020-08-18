//
//  addCreditsViewController.m
//  dating
//
//  Created by lance on 16/3/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  setting添加credits

#import "LSAddCreditsViewController.h"
#import "LSCreditDetailTableViewCell.h"
#import "LSCreditTitleTableViewCell.h"
#import "LSCreditTableViewCell.h"
#import "LSPremiumMembershipTableViewCell.h"
#import "GetLeftCreditRequest.h"
#import "LSPaymentManager.h"
#import "LSPaymentErrorCode.h"
#import "LSPremiumMembershipView.h"
#import "LSPremiumMembershipRequest.h"
#import "LSOrderProductItemObject.h"
#import "LSProductItemObject.h"
#import "DialogTip.h"
#import "LSDomainSessionRequestManager.h"
#import "LSSessionRequestManager.h"
#import "LiveRoomCreditRebateManager.h"
typedef enum AlertType {
    AlertTypeDefault = 100000,
    AlertTypeAppStorePay,
    AlertTypeCheckOrder
} AlertType;

typedef enum : NSUInteger {
    CreditsViewTypeMembership,
    CreditsViewTypeBanlance,
    CreditsViewTypeTitle,
    CreditsViewTypeCreditLevel,
    CreditsViewTypeEmptyView
} CreditsViewType;

@interface LSAddCreditsViewController () <LSPaymentManagerDelegate>

/**
 *  数据列表
 */
@property (nonatomic, strong) NSArray *tableViewDataArray;
/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) LSDomainSessionRequestManager *domainSessionManager;

/**
 *  余额
 */
@property (nonatomic, strong) NSString *money;

/**
 *  支付管理器
 */
@property (nonatomic, strong) LSPaymentManager *paymentManager;

/**
 *  当前支付订单号
 */
@property (nonatomic, strong) NSString *orderNo;
/**
 *  行数
 */
@property (nonatomic, strong) NSArray *tableViewArray;

@property (nonatomic, strong) LSOrderProductItemObject *membershipItem;

/** 购买完成显示的 */
@property (nonatomic, strong) UIAlertController *alertVC;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;
@end

@implementation LSAddCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitle = NSLocalizedStringFromSelf(@"Credits");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadLoadingActivityViewFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.paymentManager = [LSPaymentManager manager];
    [self.paymentManager addDelegate:self];

    [self getCount];
    [self getPremiumMembershipInfo];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self hideAndResetLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.`
}

#pragma mark - 界面事件
- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (void)setupContainView {
    [super setupContainView];
}

#pragma mark 设置FooterView
- (void)setupTableFooterView {

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, screenSize.width - 10, 40)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = Color(121, 121, 121, 1);
    label.text = [NSString stringWithFormat:@"%@ Learn more", self.membershipItem.desc];
    [self.tableView setTableFooterView:label];

    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:label.text];
    [richText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[label.text rangeOfString:@"Learn more"]]; //设置下划线
    [richText addAttribute:NSForegroundColorAttributeName value:Color(0, 102, 255, 1) range:[label.text rangeOfString:@"Learn more"]];
    label.attributedText = richText;

    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableFooterViewTap)]];
}

//FooterView 点击事件
- (void)tableFooterViewTap {
    LSPremiumMembershipView *view = [[LSPremiumMembershipView alloc] initWithFrame:self.view.window.bounds];
    [self.view.window addSubview:view];

    [view showMembershipView:self.membershipItem.more];
}

#pragma mark 初始化
- (void)initCustomParam {
    // 初始化父类参数
    [super initCustomParam];
    self.isShowNavBar = YES;
    
    self.backTitle = NSLocalizedString(@"", nil);

    self.orderNo = @"";
    self.money = @"0.0";

    self.domainSessionManager = [LSDomainSessionRequestManager manager];
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)dealloc {
    [self.paymentManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView {
    NSMutableArray *array = [NSMutableArray array];

    // credits数据列表

    LSProductItemObject *item = [[LSProductItemObject alloc] init];
    item.name = NSLocalizedStringFromSelf(@"CREDITS_BALANCE");
    item.price = self.money;
    [array addObject:item];

    item = [[LSProductItemObject alloc] init];
    item.name = NSLocalizedStringFromSelf(@"ADD_MORE_CREDITS");
    item.price = @"";
    [array addObject:item];

    if (self.membershipItem.title.length > 0) {
        item = [[LSProductItemObject alloc] init];
        item.name = self.membershipItem.title;
        item.price = self.membershipItem.subTitle;
        [array addObject:item];
    } else {
        item = [[LSProductItemObject alloc] init];
        item.name = NSLocalizedStringFromSelf(@"ADD_MORE_CREDITS");
        item.price = @"";
        [array addObject:item];
    }
    for (int i = 0; i < self.membershipItem.list.count; i++) {
        LSProductItemObject *item = self.membershipItem.list[i];
        [array addObject:item];
    }

    self.items = array;

    if (self.membershipItem.desc.length > 0) {
        [self setupTableFooterView];
    } else {
        [self.tableView setTableFooterView:nil];
    }

    // 主tableView
    NSMutableArray *rowArray = [NSMutableArray array];
    NSMutableDictionary *dictionary = nil;
    CGSize viewSize;
    NSValue *rowSize;

    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [LSCreditTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeBanlance] forKey:ROW_TYPE];
    [rowArray addObject:dictionary];

    // 如果有月费购买提示则显示
    if (self.membershipItem.title.length > 0) {
        dictionary = [NSMutableDictionary dictionary];
        viewSize = CGSizeMake(self.tableView.frame.size.width, 46);
        rowSize = [NSValue valueWithCGSize:viewSize];
        [dictionary setValue:rowSize forKey:ROW_SIZE];
        [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeEmptyView] forKey:ROW_TYPE];
        [rowArray addObject:dictionary];

        dictionary = [NSMutableDictionary dictionary];
        viewSize = CGSizeMake(self.tableView.frame.size.width, 46);
        rowSize = [NSValue valueWithCGSize:viewSize];
        [dictionary setValue:rowSize forKey:ROW_SIZE];
        [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeMembership] forKey:ROW_TYPE];
        [rowArray addObject:dictionary];
    } else {
        dictionary = [NSMutableDictionary dictionary];
        viewSize = CGSizeMake(self.tableView.frame.size.width, 46);
        rowSize = [NSValue valueWithCGSize:viewSize];
        [dictionary setValue:rowSize forKey:ROW_SIZE];
        [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeEmptyView] forKey:ROW_TYPE];
        [rowArray addObject:dictionary];

        dictionary = [NSMutableDictionary dictionary];
        viewSize = CGSizeMake(self.tableView.frame.size.width, 46);
        rowSize = [NSValue valueWithCGSize:viewSize];
        [dictionary setValue:rowSize forKey:ROW_SIZE];
        [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeTitle] forKey:ROW_TYPE];
        [rowArray addObject:dictionary];
    }

    for (int i = 0; i < self.membershipItem.list.count; i++) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        viewSize = CGSizeMake(self.tableView.frame.size.width, [LSCreditDetailTableViewCell cellHeight]);
        rowSize = [NSValue valueWithCGSize:viewSize];
        [dictionary setValue:rowSize forKey:ROW_SIZE];
        [dictionary setValue:[NSNumber numberWithInteger:CreditsViewTypeCreditLevel] forKey:ROW_TYPE];
        [rowArray addObject:dictionary];
    }

    self.tableViewArray = rowArray;

    if (isReloadView) {
        [self.tableView reloadData];
    }
}

- (void)cancelPay {
    self.orderNo = nil;
}

- (NSString *)messageTipsFromErrorCode:(NSString *)errorCode defaultCode:(NSString *)defaultCode {
    // 默认错误
    NSString *messageTips = NSLocalizedStringFromSelf(defaultCode);

    if (
        [errorCode isEqualToString:PAY_ERROR_INVALID_MONTHLY_CREDIT_40005] ||
        [errorCode isEqualToString:PAY_ERROR_REQUEST_SAMETIME_50000]) {
        // 具体错误
        messageTips = NSLocalizedStringFromSelf(errorCode);

    } else if (
        [errorCode isEqualToString:PAY_ERROR_OVER_CREDIT_20038] ||
        [errorCode isEqualToString:PAY_ERROR_CAN_NOT_ADD_CREDIT_20046]) {
        // 具体错误
        messageTips = NSLocalizedStringFromSelf(PAY_ERROR_TECHNICAl);
    } else if ([errorCode isEqualToString:PAY_ERROR_2]) {
        messageTips = NSLocalizedStringFromSelf(PAY_FAIL_OR_CANCEL);
    } else if (
        [errorCode isEqualToString:PAY_ERROR_NORMAL] ||
        [errorCode isEqualToString:PAY_ERROR_10003] ||
        [errorCode isEqualToString:PAY_ERROR_10005] ||
        [errorCode isEqualToString:PAY_ERROR_10006] ||
        [errorCode isEqualToString:PAY_ERROR_10007] ||
        [errorCode isEqualToString:PAY_ERROR_20014] ||
        [errorCode isEqualToString:PAY_ERROR_20015] ||
        [errorCode isEqualToString:PAY_ERROR_20030] ||
        [errorCode isEqualToString:PAY_ERROR_20031] ||
        [errorCode isEqualToString:PAY_ERROR_20032] ||
        [errorCode isEqualToString:PAY_ERROR_20033] ||
        [errorCode isEqualToString:PAY_ERROR_20035] ||
        [errorCode isEqualToString:PAY_ERROR_20037] ||
        [errorCode isEqualToString:PAY_ERROR_20039] ||
        [errorCode isEqualToString:PAY_ERROR_20040] ||
        [errorCode isEqualToString:PAY_ERROR_20041] ||
        [errorCode isEqualToString:PAY_ERROR_20042] ||
        [errorCode isEqualToString:PAY_ERROR_20043] ||
        [errorCode isEqualToString:PAY_ERROR_20044] ||
        [errorCode isEqualToString:PAY_ERROR_20045]) {
        // 普通错误
        messageTips = NSLocalizedStringFromSelf(PAY_ERROR_NORMAL);
    }

    return messageTips;
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    if ([tableView isEqual:self.tableView]) {
        count = 1;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger dataCount = 0;
    if ([tableView isEqual:self.tableView]) {
        dataCount = self.items.count;
    }
    return dataCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if ([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        height = viewSize.height;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    LSProductItemObject *item = [self.items objectAtIndex:indexPath.row];
    if ([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        // 大小
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        // 类型
        CreditsViewType type = (CreditsViewType)[[dictionarry valueForKey:ROW_TYPE] intValue];
        switch (type) {
            case CreditsViewTypeMembership: {
                LSCreditTitleTableViewCell *cell = [LSCreditTitleTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", item.name, item.price];
            } break;
            // 点数
            case CreditsViewTypeBanlance: {
                LSCreditTableViewCell *cell = [LSCreditTableViewCell getUITableViewCell:tableView];
                result = cell;
                [cell.creditBtn setTitle:self.money forState:UIControlStateNormal];
                [cell.creditBtn sizeToFit];
                cell.titleLabel.text = item.name;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } break;
            // 购买点数提示
            case CreditsViewTypeTitle: {
                LSCreditTitleTableViewCell *cell = [LSCreditTitleTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.titleLabel.hidden = NO;
                cell.titleLabel.text = item.name;
                //                cell.leftImageView.image = [UIImage imageNamed:@"AddCredits-ShopBus"];

            } break;
            case CreditsViewTypeCreditLevel: {
                // 购买点数等级显示
                LSCreditDetailTableViewCell *cell = [LSCreditDetailTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.accessoryLabel.text = item.price;
                cell.detailLabel.text = item.name;

            } break;

            case CreditsViewTypeEmptyView: {
                LSCreditTitleTableViewCell *cell = [LSCreditTitleTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.titleLabel.hidden = YES;

            } break;
            default:
                break;
        }
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LSProductItemObject *item = [self.items objectAtIndex:indexPath.row];
    NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
    CreditsViewType type = (CreditsViewType)[[dictionarry valueForKey:ROW_TYPE] intValue];
    switch (type) {
        case CreditsViewTypeCreditLevel: {
            [self showLoading];
            BOOL result = [self.paymentManager pay:item.productId];
            // 如果直接返回失败就不限士加载
            if (!result) {
                [self hideLoading];
            }

        } break;
        default:
            break;
    }
}

#pragma mark - 监听返回按钮
//实现返回按钮的功能
- (void)backToSettings {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 接口回调
- (void)getCount {
    [self showLoading];
    [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                NSLog(@"LSAddCreditsViewController::LeftCredit( 获取男士余额成功 )");
                self.money = [NSString stringWithFormat:@"%.2f", credit];
                [self reloadData:YES];
            } else {
                NSLog(@"LSAddCreditsViewController::LeftCredit( 获取男士余额失败");
            }
        });
    }];
}

- (BOOL)getPremiumMembershipInfo {
    //    if (!AppShareDelegate().isNetwork) {
    //        [self showHUDIcon:@"HUD_warning" message:NSLocalizedString(@"Tip_No_NetWork", nil) isToast:YES];
    //        return NO;
    //    }

    [self showLoading];
    LSPremiumMembershipRequest *request = [[LSPremiumMembershipRequest alloc] init];
    request.finishHandler = ^(BOOL success, NSString *_Nonnull errnum, NSString *_Nonnull errmsg, LSOrderProductItemObject *item) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSLog(@"LSAddCreditsViewController::getPremiumMembershipInfo(获取会员充值列表成功 )");
                self.membershipItem = item;
                NSMutableArray *productIdList = [NSMutableArray array];
                for (LSProductItemObject *obj in item.list) {
                    [productIdList addObject:obj.productId];
                }
                NSSet *products = [NSSet setWithArray:productIdList];
                BOOL result = [self.paymentManager getProductsInfo:products];
                if (!result) {
                    [self hideLoading];
                }
            } else {
                [self hideLoading];
                NSLog(@"LSAddCreditsViewController::getPremiumMembershipInfo(获取会员充值列表失败)  errmun: %@ , errmsg: %@", errnum, errmsg);
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    return [self.domainSessionManager sendRequest:request];
}

#pragma mark - Apple支付回调
- (void)onGetProductsInfo:(LSPaymentManager *)mgr products:(NSArray<SKProduct *> *)products {
    NSLog(@"LSAddCreditsViewController::onGetProductsInfo( 获取订单成功, orderNo : %@ )", products);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
        if (products.count > 0) {
            for (SKProduct *product in products) {
                NSString *productLocalePrice = [NSString stringWithFormat:@"%@ %@%@", [product.priceLocale objectForKey:NSLocaleCurrencyCode], [product.priceLocale objectForKey:NSLocaleCurrencySymbol], product.price];
                for (LSProductItemObject *obj in self.membershipItem.list) {
                    if ([obj.productId isEqualToString:product.productIdentifier]) {
                        obj.price = productLocalePrice;
                    }
                }
            }
            [self reloadData:YES];
        } else {
            [[DialogTip dialogTip] showDialogTip:self.view tipText:@""];
        }
    });
}

- (void)onGetOrderNo:(LSPaymentManager *_Nonnull)mgr result:(BOOL)result code:(NSString *_Nonnull)code orderNo:(NSString *_Nonnull)orderNo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (result) {
            NSLog(@"LSAddCreditsViewController::onGetOrderNo( 获取订单成功, orderNo : %@ )", orderNo);
            self.orderNo = orderNo;
        } else {
            NSLog(@"LSAddCreditsViewController::onGetOrderNo( 获取订单失败, code : %@ )", code);
            // 隐藏菊花
            [self hideLoading];

            NSString *tips = [self messageTipsFromErrorCode:code defaultCode:PAY_ERROR_NORMAL];
            tips = [NSString stringWithFormat:@"%@ (%@)", tips, code];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:tips preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self alertView:AlertTypeDefault clickCancleOrOther:0];
            }];
            [alertVC addAction:cancelAC];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    });
}

- (void)onAppStorePay:(LSPaymentManager *_Nonnull)mgr result:(BOOL)result orderNo:(NSString *_Nonnull)orderNo canRetry:(BOOL)canRetry {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.orderNo isEqualToString:orderNo]) {
            if (result) {
                NSLog(@"LSAddCreditsViewController::onAppStorePay( AppStore支付成功, orderNo : %@ )", orderNo);
            } else {
                NSLog(@"LSAddCreditsViewController::onAppStorePay( AppStore支付失败, orderNo : %@, canRetry :%d )", orderNo, canRetry);
                // 隐藏菊花
                [self hideLoading];

                if (canRetry) {
                    // 弹出重试窗口
                    NSString *tips = [self messageTipsFromErrorCode:PAY_ERROR_OTHER defaultCode:PAY_ERROR_OTHER];
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:tips preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self alertView:AlertTypeAppStorePay clickCancleOrOther:0];
                    }];
                    UIAlertAction *otherAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self alertView:AlertTypeAppStorePay clickCancleOrOther:1];
                    }];
                    [alertVC addAction:cancelAC];
                    [alertVC addAction:otherAC];
                    [self presentViewController:alertVC animated:YES completion:nil];
                } else {
                    // 弹出提示窗口
                    NSString *tips = [self messageTipsFromErrorCode:PAY_ERROR_NORMAL defaultCode:PAY_ERROR_NORMAL];
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:tips preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self alertView:AlertTypeDefault clickCancleOrOther:0];
                    }];
                    [alertVC addAction:cancelAC];
                    [self presentViewController:alertVC animated:YES completion:nil];
                }
            }
        }
    });
}

- (void)onCheckOrder:(LSPaymentManager *_Nonnull)mgr result:(BOOL)result code:(NSString *_Nonnull)code orderNo:(NSString *_Nonnull)orderNo canRetry:(BOOL)canRetry {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.orderNo isEqualToString:orderNo]) {
            if (result) {
                NSLog(@"LSAddCreditsViewController::onCheckOrder( 验证订单成功, orderNo : %@ )", orderNo);
            } else {
                NSLog(@"LSAddCreditsViewController::onCheckOrder( 验证订单失败, orderNo : %@, canRetry :%d, code : %@ )", orderNo, canRetry, code);
                // 隐藏菊花
                [self hideLoading];

                if (canRetry) {
                    // 弹出重试窗口
                    NSString *tips = [self messageTipsFromErrorCode:PAY_ERROR_OTHER defaultCode:PAY_ERROR_OTHER];
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:tips preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self alertView:AlertTypeCheckOrder clickCancleOrOther:0];
                    }];
                    UIAlertAction *otherAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self alertView:AlertTypeCheckOrder clickCancleOrOther:1];
                    }];
                    [alertVC addAction:cancelAC];
                    [alertVC addAction:otherAC];
                    [self presentViewController:alertVC animated:YES completion:nil];
                } else {
                    // 弹出提示窗口
                    NSString *tips = [self messageTipsFromErrorCode:code defaultCode:PAY_ERROR_NORMAL];
                    tips = [NSString stringWithFormat:@"%@ (%@)", tips, code];
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:tips preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self alertView:AlertTypeDefault clickCancleOrOther:0];
                    }];
                    [alertVC addAction:cancelAC];
                    [self presentViewController:alertVC animated:YES completion:nil];
                }
            }
        }
    });
}

- (void)onPaymentFinish:(LSPaymentManager *_Nonnull)mgr orderNo:(NSString *_Nonnull)orderNo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSAddCreditsViewController::onPaymentFinish( 支付完成 orderNo : %@ )", orderNo);
        // 隐藏菊花
        [self hideLoading];
        // 弹出提示窗口
        NSString *tips = NSLocalizedStringFromSelf(@"PAY_SUCCESS");
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:tips preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self alertView:AlertTypeDefault clickCancleOrOther:0];
        }];
        [alertVC addAction:cancelAC];
        if (!self.isBackground) {
            [self presentViewController:alertVC animated:YES completion:nil];
        } else {
            self.alertVC = alertVC;
        }
    });
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if (_isBackground == NO) {
        _isBackground = YES;
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (_isBackground == YES) {
        _isBackground = NO;
        if (self.alertVC) {
            [self presentViewController:self.alertVC animated:YES completion:nil];
        }
    }
}

#pragma mark - 点击弹窗提示
- (void)alertView:(NSInteger)tag clickCancleOrOther:(NSInteger)index {
    switch (tag) {
        case AlertTypeDefault: {
            // 买点成功的提示
            // 清空订单号
            [self cancelPay];
            
            // 刷新点数
            [self getCount];
            
            [self getPremiumMembershipInfo];
            
            self.alertVC = nil;
        } break;
        case AlertTypeAppStorePay: {
            // Apple支付中
            switch (index) {
                case 0: {
                    // 点击取消
                    [self cancelPay];
                } break;
                case 1: {
                    // 点击重试
                    [self showLoading];
                    [self.paymentManager retry:self.orderNo];
                } break;
                default:
                    break;
            }
        }break;
        case AlertTypeCheckOrder: {
            // 账单验证中
            switch (index) {
                case 0:{
                    // 点击取消, 自动验证
                    [self.paymentManager autoRetry:self.orderNo];
                    [self cancelPay];
                }break;
                case 1:{
                    // 点击重试, 手动验证
                    [self showLoading];
                    [self.paymentManager retry:self.orderNo];
                }break;
                default:
                    break;
            }
        }
        default:
            break;
    }
}

@end
