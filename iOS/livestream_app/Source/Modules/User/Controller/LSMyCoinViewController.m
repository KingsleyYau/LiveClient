//
//  LSMyCoinViewController.m
//  livestream
//
//  Created by test on 2017/12/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSMyCoinViewController.h"
#import "MyCoinHeaderView.h"
#import "MyCoinTableViewCell.h"
#import "ProductItemObject.h"
#import "LSPaymentManager.h"
#import "GetLeftCreditRequest.h"
#import "LSPremiumMembershipRequest.h"
#import "LSImageViewLoader.h"
#import "PremiumMembershipView.h"


@interface LSMyCoinViewController ()<UITableViewDataSource,UITableViewDelegate,PaymentManagerDelegate>


/** 头部 */
@property (nonatomic, strong) MyCoinHeaderView *headerView;

/**
 *  支付管理器
 */
@property (nonatomic, strong) LSPaymentManager* paymentManager;

/**  */
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;

/**
 *  当前支付订单号
 */
@property (nonatomic, strong) NSString* orderNo;

/** 信息 */
@property (nonatomic, strong) LSOrderProductItemObject* productItem;

@end

@implementation LSMyCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
//    [self reloadData:YES];
    [self getCoinLevel];
}

- (void)initCustomParam {
    [super initCustomParam];
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.paymentManager = [LSPaymentManager manager];
    [self.paymentManager addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void)dealloc {
    [self.paymentManager removeDelegate:self];
}


- (void)setupContainView {
    [super setupContainView];
    [self setupTableView];
    self.title = NSLocalizedStringFromSelf(@"My Coins");
}


- (void)setupTableView {
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.headerView = [[MyCoinHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 180)];
    self.tableView.tableHeaderView = self.headerView;
    
    UIView *vc =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.5)];
    vc.backgroundColor = COLOR_WITH_16BAND_RGB(0xF1D7FF);
    self.tableView.tableFooterView = vc;
    
    self.tableView.separatorColor = COLOR_WITH_16BAND_RGB(0xF1D7FF);
}

#pragma mark 设置FooterView
- (void)setupTableFooterView {
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, screenSize.width - 10, 40)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = COLOR_WITH_16BAND_RGB(0x797979);
    label.text = [NSString stringWithFormat:@"%@ Lean more",self.productItem.desc];
    [self.tableView setTableFooterView:label];
    
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:label.text];
    [richText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[label.text rangeOfString:@"Lean more"]];//设置下划线
    [richText addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x0066FF) range:[label.text rangeOfString:@"Lean more"]];
    label.attributedText = richText;
    
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tableFooterViewTap)]];
}

//FooterView 点击事件
- (void)tableFooterViewTap
{
    PremiumMembershipView * view = [[PremiumMembershipView alloc]initWithFrame:self.view.window.bounds];
    [self.view.window addSubview:view];

    [view showMembershipView:self.productItem.more];
}

- (void)reloadData:(BOOL)isReloadView {
    
//    NSMutableArray *array = [NSMutableArray array];
//    LSProductItemObject *item = [[LSProductItemObject alloc] init];
//    item.name = @"100";
//    item.productId = @"";
//    item.price = @"USD 0.99";
//    [array addObject:item];
//
//    item = [[LSProductItemObject alloc] init];
//    item.name = @"1000";
//    item.productId = @"";
//    item.price = @"USD 9.99";
//    [array addObject:item];
//
//
//    item =  [[LSProductItemObject alloc] init];
//    item.price = @"USD 99.99";
//    item.productId = @"";
//    item.name = @"10000";
//
//    [array addObject:item];
//    item =  [[LSProductItemObject alloc] init];
//    item.price = @"USD 299.99";
//    item.productId = @"";
//    item.name = @"20000";
//    [array addObject:item];
//    self.items = array;
    NSMutableArray *array = [NSMutableArray array];

    for (int i = 0;i <self.productItem.list.count;i++) {
        LSProductItemObject *item = self.productItem.list[i];
        [array addObject:item];
    }

    self.items = array;

    if (self.productItem.desc.length > 0) {
        [self setupTableFooterView];
    }else {
        UIView *vc =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.5)];
        vc.backgroundColor = COLOR_WITH_16BAND_RGB(0xF1D7FF);
        self.tableView.tableFooterView = vc;
//        [self.tableView setTableFooterView:nil];
    }
    if(isReloadView) {
        [self.tableView reloadData];
    }
}



#pragma mark - dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
      return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MyCoinTableViewCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    LSProductItemObject *item = [self.items objectAtIndex:indexPath.row];
    MyCoinTableViewCell *cell = [MyCoinTableViewCell getUITableViewCell:self.tableView];
    result = cell;
    cell.coinCount.text = item.name;
    [cell.coinPrice setTitle:item.price forState:UIControlStateNormal];
    [[LSImageViewLoader loader] stop];
    [[LSImageViewLoader loader] loadImageWithImageView:cell.coinBalanceIcon options:0 imageUrl:item.icon placeholderImage:[UIImage imageNamed:@"User_MyCoin_Star"]];

    return result;
}


#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
       [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LSProductItemObject *item = [self.items objectAtIndex:indexPath.row];
//    if (indexPath.row == 0) {
//        [self.paymentManager pay:@"SP2003"];
        [self.paymentManager pay:item.productId];
//    }
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    self.headerView = [[MyCoinHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 180)];
//    return self.headerView;
//}

- (void)cancelPay {
    self.orderNo = nil;
}

- (NSString* )messageTipsFromErrorCode:(NSString *)errorCode defaultCode:(NSString *)defaultCode {
    // 默认错误
    NSString* messageTips = NSLocalizedStringFromSelf(defaultCode);
    

    
    return messageTips;
}



#pragma mark - Apple支付回调
- (void)onGetOrderNo:(LSPaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( result ) {
            NSLog(@"LSMyCoinViewController::onGetOrderNo( 获取订单成功, orderNo : %@ )", orderNo);
            self.orderNo = orderNo;
        } else {
            NSLog(@"LSMyCoinViewController::onGetOrderNo( 获取订单失败, code : %@ )", code);
            // 隐藏菊花
            [self hideLoading];
            
            NSString* tips = [self messageTipsFromErrorCode:code defaultCode:@""];
            tips = [NSString stringWithFormat:@"%@ (%@)",tips,code];

        }
    });
}

- (void)onAppStorePay:(LSPaymentManager* _Nonnull)mgr result:(BOOL)result orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [self.orderNo isEqualToString:orderNo] ) {
            if( result ) {
                NSLog(@"LSMyCoinViewController::onAppStorePay( AppStore支付成功, orderNo : %@ )", orderNo);
            } else {
                NSLog(@"LSMyCoinViewController::onAppStorePay( AppStore支付失败, orderNo : %@, canRetry :%d )", orderNo, canRetry);
                // 隐藏菊花
                [self hideLoading];
                
                if( canRetry ) {
                    // 弹出重试窗口
                    NSString* tips = [self messageTipsFromErrorCode:@"" defaultCode:@""];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:tips preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                   
                    }]];
                    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", @"Retry") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];

                    
                } else {
                    // 弹出提示窗口
                    NSString* tips = [self messageTipsFromErrorCode:@"" defaultCode:@""];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"test" preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }]];

                    [self presentViewController:alert animated:YES completion:nil];
                }
                

            }
        }
    });
}

- (void)onCheckOrder:(LSPaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [self.orderNo isEqualToString:orderNo] ) {
            if( result ) {
                NSLog(@"LSMyCoinViewController::onCheckOrder( 验证订单成功, orderNo : %@ )", orderNo);
            } else {
                NSLog(@"LSMyCoinViewController::onCheckOrder( 验证订单失败, orderNo : %@, canRetry :%d, code : %@ )", orderNo, canRetry, code);
                // 隐藏菊花
                [self hideLoading];
                
                if( canRetry ) {
                    // 弹出重试窗口

                    
                } else {
                    // 弹出提示窗口

                }
            }
        }
    });
}

- (void)onPaymentFinish:(LSPaymentManager* _Nonnull)mgr orderNo:(NSString* _Nonnull)orderNo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSMyCoinViewController::onPaymentFinish( 支付完成 orderNo : %@ )", orderNo);
        // 隐藏菊花
        [self hideLoading];
        
        // 弹出提示窗口
        // 弹出提示窗口
        NSString* tips = [self messageTipsFromErrorCode:@"" defaultCode:@""];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Success" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        // 清空订单号
        [self cancelPay];
        
        // 刷新点数
        

        

    });
}


- (BOOL)getLeftCoin {
    GetLeftCreditRequest *request = [[GetLeftCreditRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, double credit) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headerView.coinCount.text = [NSString stringWithFormat:@"%lf",credit];
        });
    };
    return [self.sessionManager sendRequest:request];
}


- (BOOL)getCoinLevel {
    LSPremiumMembershipRequest *request = [[LSPremiumMembershipRequest alloc] init];
    request.siteId = @"5";
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSOrderProductItemObject * _Nonnull productItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.productItem = productItem;
                [self reloadData:YES];
            }

        });
    };
    return [self.sessionManager sendRequest:request];
}
@end
