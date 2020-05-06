//
//  LSCheckOutViewController.m
//  livestream
//
//  Created by test on 2019/10/10.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSCheckOutViewController.h"
#import "LSCheckOutCartGiftRequest.h"
#import "LSAddCartGiftRequest.h"
#import "LSRemoveCartGiftRequest.h"
#import "LSChangeCartGiftNumberRequest.h"
#import "LSGreetingCardPreviewViewController.h"
#import "LSCreateGiftOrderRequest.h"
#import "LSShadowView.h"
#import "DialogTip.h"
#import "LSLoginManager.h"
#import "LSUserInfoManager.h"
#import "LSContinueNavView.h"
#import "LSWebPaymentViewController.h"
#import "LiveUrlHandler.h"
#import "LSGetDeliveryListRequest.h"
#define maxCount 250

@interface LSCheckOutViewController ()
@property (nonatomic, strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet UIView *noProductView;
@property (weak, nonatomic) IBOutlet UIButton *greetingsPreview;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIButton *goToStoreBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalPriceBottomDistance;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceFee;
@property (nonatomic, assign) CGFloat scrollViewOffy;
@property (weak, nonatomic) IBOutlet UIView *loadingDataView;
/** 贺卡内容 */
@property (nonatomic, copy) NSString *greetingMsg;
/** 特殊要求 */
@property (nonatomic, copy) NSString *specialMsg;
@property (nonatomic, strong) LSContinueNavView * navView;
/** 当前订单 */
@property (nonatomic, copy) NSString *orderNum;
@property (weak, nonatomic) IBOutlet UIImageView *greetingCardTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *greetingCardName;
@property (weak, nonatomic) IBOutlet UILabel *greetingCardPrice;
@property (weak, nonatomic) IBOutlet UIImageView *greetingCardSmallIcon;
@property (weak, nonatomic) IBOutlet UILabel *festivalName;

@end

@implementation LSCheckOutViewController


- (void)dealloc {
    NSLog(@"LSCheckOutViewController::dealloc()");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)initCustomParam {
    [super initCustomParam];
    
    self.isShowNavBar = YES;
    
    self.scrollViewOffy = 0;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.sessionManager = [LSSessionRequestManager manager];
    self.items = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self setupUI];
    
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
    self.navView.checkoutBtn.hidden = YES;
    self.navigationItem.titleView = self.navView;
    [self.navView setName:self.anchorName andHeadImage:self.anchorImageUrl];
    [self getAnchorDetail];
}

- (void)navBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setupUI {
    self.greetingMsgTextView.layer.borderWidth = 1;
    self.greetingMsgTextView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x999999).CGColor;
    self.greetingMsgTextView.layer.cornerRadius = 4.0f;
    self.greetingMsgTextView.layer.masksToBounds = YES;
    self.greetingMsgTextView.delegate = self;
    self.greetingMsgTextView.placeholder = @"Type your message here";
    
    self.specialDeliveryMsg.layer.borderWidth = 1;
    self.specialDeliveryMsg.layer.borderColor = COLOR_WITH_16BAND_RGB(0x999999).CGColor;
    self.specialDeliveryMsg.layer.cornerRadius = 4.0f;
    self.specialDeliveryMsg.layer.masksToBounds = YES;
    self.specialDeliveryMsg.delegate = self;
    self.specialDeliveryMsg.placeholder = @"Leave us a message here if you have any special request regarding the delivery (such as exact day delivery).";
    
    
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc]initWithString:self.greetingsPreview.titleLabel.text];
    
    [attributeString addAttributes:@{
        NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
    }
                             range:NSMakeRange(0, attributeString.length)];
    [self.greetingsPreview setAttributedTitle:attributeString forState:UIControlStateNormal];
    
    
    self.totalPriceView.layer.shadowOffset = CGSizeMake(-3, -3);
    self.totalPriceView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.18].CGColor;
    self.totalPriceView.layer.shadowRadius = 3;
    self.totalPriceView.layer.shadowOpacity = 0.5;
    if (IS_IPHONE_X) {
        self.totalPriceBottomDistance.constant = 44.0f;
        self.scrollViewBottomDistance.constant = 44.0f;
    }
    
    
    self.continueBtn.layer.cornerRadius = 6.0f;
    self.continueBtn.layer.masksToBounds = YES;
    
    LSShadowView *shadow = [[LSShadowView alloc] init];
    [shadow showShadowAddView:self.continueBtn];
    
    self.goToStoreBtn.layer.borderWidth = 1;
    self.goToStoreBtn.layer.borderColor = [UIColor colorWithRed:56 / 255.0 green:56 / 255.0 blue:0 alpha:1].CGColor;
    self.goToStoreBtn.layer.cornerRadius = 6.0f;
    self.goToStoreBtn.layer.masksToBounds = YES;
    
    self.noProductView.hidden = YES;
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTap)];
    [self.view addGestureRecognizer:tap];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    [self getAnchorDetail];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.viewDidAppearEver) {
        self.loadingDataView.hidden = NO;
        [self getCheckOutList];
    }
    if (self.orderNum.length > 0) {
        [self getDeliveryList];
    }
    
}

#pragma mark - 数据请求接口
/**
 * 获取女士资料
 */
- (void)getAnchorDetail {
    if (self.anchorName == nil || self.anchorImageUrl == nil) {
        [[LSUserInfoManager manager] getUserInfo:self.anchorId finishHandler:^(LSUserInfoModel *item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.anchorName = item.nickName;
                [self.navView setName:item.nickName andHeadImage:item.photoUrl];
            });
        }];
    }
}


- (void)getCheckOutList {
    LSCheckOutCartGiftRequest *request = [[LSCheckOutCartGiftRequest alloc] init];
    request.anchorId = self.anchorId;
    [self showLoading];
    self.failView.hidden = YES;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSCheckoutItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingDataView.hidden = YES;
            [self hideLoading];
            if (success) {
                [self.items removeAllObjects];
                [self reloadCheckOutList:item];
            }else {
                self.failIcon.image = [UIImage imageNamed:@"Home_Hot&follow_fail"];
                self.failView.hidden = NO;
            }
        });
    };
    
    [self.sessionManager sendRequest:request];
}

- (void)getDeliveryList {
    LSGetDeliveryListRequest *request = [[LSGetDeliveryListRequest alloc] init];
    [self showLoading];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSDeliveryItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSCheckOutViewController::getDeliveryList( [%@], count : %ld )", BOOL2SUCCESS(success),  (long)array.count);
            [self hideLoading];
            if (success) {
                BOOL finishOrder = NO;
                // 遍历订单列表查看是否存在该订单
                for (LSDeliveryItemObject *item in array) {
                    if ([item.orderNumber isEqualToString:self.orderNum]) {
                        finishOrder = YES;
                        break;
                    }
                }
                // 存在则成功直接跳转
                if (finishOrder) {
                    self.orderNum = @"";
                    NSURL *url = [[LiveUrlHandler shareInstance] createFlowerStore:LiveUrlGiftFlowerListTypeDelivery];
                    [[LiveUrlHandler shareInstance] handleOpenURL:url];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}


- (void)reloadCheckOutList:(LSCheckoutItemObject *)item {
    if (item.giftList.count == 0) {
        self.noProductView.hidden = NO;
    }
    NSMutableArray *tempArray = [NSMutableArray array];
    BOOL hasGreetingCard = NO;
    // 礼物列表,是否具有贺卡
    for (LSCheckoutGiftItemObject *itemObject in item.giftList) {
        if (itemObject.isGreetingCard) {
            hasGreetingCard = YES;
        }
        [tempArray addObject:itemObject];
    }
    
    // 是否有贺卡
    if (hasGreetingCard || item.greetingCard.giftNumber > 0) {
        self.freeGreetingCard.hidden = NO;
        self.freeGreetingCardHeight.constant = 80;
    }else {
        self.freeGreetingCard.hidden = YES;
        self.freeGreetingCardHeight.constant = 0;
    }
    
    self.items = tempArray;
    [self reloadTableView];
    
    // 贺卡类型
    if (item.greetingCard.isBirthday) {
        // 生日贺卡优惠
        self.greetingCardName.text = @"Birthday Greeting Card";
        self.greetingCardPrice.text = [NSString stringWithFormat:@"USD 0.00 USD %0.2f",item.greetingCard.giftPrice];
        NSString * str = [NSString stringWithFormat:@"USD %0.2f",item.greetingCard.giftPrice];
        NSRange discountRange = [self.greetingCardPrice.text rangeOfString:str];
         NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:self.greetingCardPrice.text];
                [attributeStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x999999) range:discountRange];
                [attributeStr addAttribute:NSStrikethroughStyleAttributeName value:
        @(NSUnderlineStyleSingle) range:discountRange];
        self.greetingCardPrice.attributedText = attributeStr;
    }else {
        self.greetingCardName.text = @"Greeting Card";
    }
    self.festivalName.text = item.holidayName;
    [[LSImageViewLoader loader] loadHDListImageWithImageView:self.greetingCardTypeIcon options:0 imageUrl:item.greetingCard.giftImg placeholderImage:nil finishHandler:nil];
    [[LSImageViewLoader loader] loadHDListImageWithImageView:self.greetingCardSmallIcon options:0 imageUrl:item.greetingCard.giftImg placeholderImage:nil finishHandler:nil];

    
    // 节日价格
    self.deliveryFeesPrice.text = [NSString stringWithFormat:@"USD %.2f",item.deliveryPrice];
    self.discountPrice.text = [NSString stringWithFormat:@"-USD %.2f",fabs(item.holidayPrice)];
    
    self.greetingMsgTextView.text = item.greetingmessage;
    self.specialDeliveryMsg.text = item.specialDeliveryRequest;
    
    self.totalPriceFee.text = [NSString stringWithFormat:@"USD %.2f",item.totalPrice];
    
    
    // 特殊要求信息
    if (item.specialDeliveryRequest.length == 0 && self.specialMsg.length > 0) {
        self.specialDeliveryMsg.text = self.specialMsg;
    }
    
    // 贺卡信息
    if (item.greetingmessage.length == 0 && self.greetingMsg.length > 0) {
        self.greetingMsgTextView.text = self.greetingMsg;
    }
    
    // 贺卡以及要求字数控制
    self.specialDeliveryMsgCount.text = [NSString stringWithFormat:@"%d",(int)(maxCount - self.specialDeliveryMsg.text.length)];
    self.greetingMsgCount.text = [NSString stringWithFormat:@"%d",(int)(maxCount - self.greetingMsgTextView.text.length)];
}

- (void)reloadTableView {
    if (self.items.count == 0) {
        self.noProductView.hidden = NO;
    }
    self.tableViewHeight.constant = self.items.count * 80;
    [self.tableView reloadData];
}

- (void)lsListViewControllerDidClick:(UIButton *)sender {
    self.failView.hidden = YES;
    [self getAnchorDetail];
    [self getCheckOutList];
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    
    if (self.items.count > 0) {
        number = self.items.count;
    }
    
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [[UITableViewCell alloc] init];
    LSGiftProductTableViewCell *cell = [LSGiftProductTableViewCell getUITableViewCell:tableView];
    tableViewCell = cell;
    cell.giftProductDelegate = self;
    cell.tag = indexPath.row;
    if (indexPath.row < self.items.count) {
        LSCheckoutGiftItemObject *item = [self.items objectAtIndex:indexPath.row];
        cell.giftName.text = [NSString stringWithFormat:@"%@ - %@",item.giftId,item.giftName];
        cell.giftPrice.text = [NSString stringWithFormat:@"USD %.2f",item.giftPrice * item.giftNumber];
        cell.giftTextFeild.text = [NSString stringWithFormat:@"%d",item.giftNumber];
        cell.tag = indexPath.row;
        [cell.imageViewLoader stop];
        [cell.imageViewLoader loadHDListImageWithImageView:cell.giftImageView
                                                   options:0
                                                  imageUrl:item.giftImg
                                          placeholderImage:nil
                                             finishHandler:nil];
        
    }
    
    
    return tableViewCell;
}


- (void)textViewDidChange:(UITextView *)textView {
    if ([textView isEqual:self.greetingMsgTextView]) {
        // 超过字符限制
        NSString *toBeString = textView.text;
        // 获取是否存在高亮部分
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > maxCount) {
                textView.text = [textView.text substringToIndex:maxCount];
                self.greetingMsgCount.text = @"0";
            }else {
                self.greetingMsgCount.text = [NSString stringWithFormat:@"%d", (int)(maxCount - toBeString.length)];
            }
        }
    }
    
    if ([textView isEqual:self.specialDeliveryMsg]) {
        // 超过字符限制
        NSString *toBeString = textView.text;
        // 获取是否存在高亮部分
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > maxCount) {
                textView.text = [textView.text substringToIndex:maxCount];
                self.specialDeliveryMsgCount.text = @"0";
            }else {
                 self.specialDeliveryMsgCount.text = [NSString stringWithFormat:@"%d", (int)(maxCount - toBeString.length)];
            }
        }
    }

    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([textView isEqual:self.greetingMsgTextView]) {
        self.greetingMsg = textView.text;
        int count  = (int)(maxCount - textView.text.length);
    
        if (count >= 0) {
            self.greetingMsgCount.text = [NSString stringWithFormat:@"%d", count];
        }else {
            self.greetingMsgCount.text = @"0";
            // 判断是否删除字符
            if ('\000' != [text UTF8String][0] && ![text isEqualToString:@"\b"]) {
                // 非删除字符，不允许输入
                return  NO;
            }
        }
    }
    
    if ([textView isEqual:self.specialDeliveryMsg]) {
        self.specialMsg = textView.text;
        int count  = (int)(maxCount - textView.text.length);
        if (count >= 0) {
            self.specialDeliveryMsgCount.text = [NSString stringWithFormat:@"%d",count];
        }else {
            self.specialDeliveryMsgCount.text = @"0";
            // 判断是否删除字符
            if ('\000' != [text UTF8String][0] && ![text isEqualToString:@"\b"]) {
                // 非删除字符，不允许输入
                return NO;
            }
        }
    }

    return YES;
}


-(void)lsGiftProductTableViewCellDidSelectChangeGiftNum:(LSGiftProductTableViewCell *)cell num:(int)num {
    [self updateCheckoutGiftCount:cell num:num];
}


- (void)updateCheckoutGiftCount:(LSGiftProductTableViewCell *)cell num:(int)num {
    LSCheckoutGiftItemObject *item = [self.items objectAtIndex:cell.tag];
    if (cell.giftTextFeild.text.intValue > 99 || cell.giftTextFeild.text.intValue < 1) {
        [self showNumErrorDialog];
        cell.giftTextFeild.text = [NSString stringWithFormat:@"%d",num];
        cell.giftPrice.text = [NSString stringWithFormat:@"USD %.2f",item.giftPrice * num];
        return;
    }
    LSChangeCartGiftNumberRequest *requset = [[LSChangeCartGiftNumberRequest alloc] init];
    requset.anchorId = self.anchorId;
    requset.giftId = item.giftId;
    requset.giftNumber = [cell.giftTextFeild.text intValue];
    self.view.userInteractionEnabled = NO;
    requset.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        NSLog(@"LSCheckOutViewController::sendRequestChangeGiftNum[请求修改鲜花礼品数量 success : %@, errnum : %d, errmsg : %@]",BOOL2SUCCESS(success),errnum,errmsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
            if (success) {
                [self getCheckOutList];
            }else {
                cell.giftTextFeild.text = [NSString stringWithFormat:@"%d",num];
                cell.giftPrice.text = [NSString stringWithFormat:@"USD %.2f",item.giftPrice * num];
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:requset];
}


- (void)lsGiftProductTableViewCellDidSelectRemoveGift:(LSGiftProductTableViewCell *)cell {
    LSCheckoutGiftItemObject *item = [self.items objectAtIndex:cell.tag];
    LSRemoveCartGiftRequest *request = [[LSRemoveCartGiftRequest alloc] init];
    request.anchorId = self.anchorId;
    request.giftId = item.giftId;
    self.view.userInteractionEnabled = NO;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        NSLog(@"LSCheckOutViewController::sendRequestRemoveGift[请求删除鲜花礼品 success : %@, errnum : %d, errmsg : %@]",BOOL2SUCCESS(success),errnum,errmsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
            if (success) {
                NSInteger index = 0;
                for (index = 0; index < self.items.count; index++) {
                    LSCheckoutGiftItemObject *model = [self.items objectAtIndex:index];
                    if ([item.giftId isEqualToString:model.giftId]) {
                        break;
                    }
                }
                [self getCheckOutList];
            }else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)lsGiftProductTableViewCell:(LSGiftProductTableViewCell *)cell DidChangeCount:(UITextField *)textField lastNum:(int)num{
    LSCheckoutGiftItemObject *item  = [[LSCheckoutGiftItemObject alloc] init];
    if (cell.tag < self.items.count) {
        item = [self.items objectAtIndex:cell.tag];
    }
    
    if ([textField.text isEqualToString:@"0"] || textField.text.length >= 3) {
        [self showNumErrorDialog];
        cell.giftTextFeild.text = [NSString stringWithFormat:@"%d",num];
        cell.giftPrice.text = [NSString stringWithFormat:@"USD %.2f",item.giftPrice * num];
        return;
    }
    if ([cell.giftTextFeild.text intValue] != num) {
        [self updateCheckoutGiftCount:cell num:num];
    }else {
        cell.giftTextFeild.text = [NSString stringWithFormat:@"%d",num];
        cell.giftPrice.text = [NSString stringWithFormat:@"USD %.2f",item.giftPrice * num];
    }
    
    
}


- (void)showNumErrorDialog {
    [[DialogTip dialogTip] showDialogTip:self.view tipText:@"You can only add 1-99 items."];
}

#pragma mark - 按钮点击事件
- (IBAction)greetingPreviewAction:(id)sender {
    LSGreetingCardPreviewViewController *vc = [[LSGreetingCardPreviewViewController alloc] initWithNibName:nil bundle:nil];
    vc.greetingCardMsg = self.greetingMsgTextView.text;
    vc.greetingCardOwer = self.anchorName;
    [self.navigationController pushViewController:vc animated:YES];
}  


- (IBAction)continueActionClick:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
    NSURL *url = [[LiveUrlHandler shareInstance] createFlowerGightByAnchorId:self.anchorId];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

- (IBAction)goToStoreActionClick:(id)sender {
    NSURL *url = [[LiveUrlHandler shareInstance] createFlowerStore:LiveUrlGiftFlowerListTypeStore];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

- (IBAction)payNowAction:(id)sender {
       [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (self.greetingMsgTextView.text.length == 0) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:@"Please enter your greeting message." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertVc addAction:okAction];
        [self presentViewController:alertVc animated:YES completion:nil];
        return;
    }
    
    LSCreateGiftOrderRequest *reqest = [[LSCreateGiftOrderRequest alloc] init];
    reqest.anchorId = self.anchorId;
    reqest.greetingMessage = self.greetingMsgTextView.text;
    reqest.specialDeliveryRequest = self.specialDeliveryMsg.text;
    [self showLoading];
    reqest.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *orderNumber) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                self.orderNum = orderNumber;
                LSWebPaymentViewController *vc = [[LSWebPaymentViewController alloc] initWithNibName:nil bundle:nil];
                vc.orderNo = orderNumber;
                [self.navigationController pushViewController:vc animated:YES];
            }else {
                if (errnum == HTTP_LCC_ERR_FAIL) {
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                    return ;
                }
                
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:errmsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
                [alertVc addAction:okAction];
                [self presentViewController:alertVc animated:YES completion:nil];
            }
        });
    };
    [self.sessionManager sendRequest:reqest];
}



#pragma mark - 关闭键盘事件事件
- (void)scrollViewTap {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


#pragma mark -KeyboardNSNotification
- (void)keyboardDidShow:(NSNotification *)notification {
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // 键盘处理方法1
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    UIView *firstReponseView = [UIResponder lsKeyboardCurrentFirstResponder];
    if ([firstReponseView isKindOfClass:[UIAlertController class]]) {
        return;
    }
    CGFloat y = [firstReponseView convertPoint:CGPointZero toView:[UIApplication sharedApplication].keyWindow].y;
    CGFloat bottom = y + firstReponseView.frame.size.height;
    CGPoint point = self.scrollView.contentOffset;
    NSLog(@"keyboardWillShow  %@",NSStringFromCGPoint(point));
    if(bottom > SCREEN_HEIGHT - keyboardRect.size.height) {
        [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
    }

    
    
    // 键盘遮挡处理2
//    UIView *firstReponseView = [UIResponder lsKeyboardCurrentFirstResponder];
//    if ([firstReponseView isKindOfClass:[UIAlertController class]]) {
//        return;
//    }else {
//        NSDictionary* info = [notification userInfo];
//        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//        self.scrollView.contentInset = contentInsets;
//        self.scrollView.scrollIndicatorInsets = contentInsets;
//
//        CGRect aRect = self.scrollView.frame;
//        aRect.size.height -= kbSize.height;
//        CGPoint origin = [firstReponseView convertPoint:CGPointZero toView:self.scrollView];
//        if (!CGRectContainsPoint(aRect, origin) ) {
//            if (IS_IPHONE_X) {
//                CGPoint scrollPoint = CGPointMake(0.0, origin.y - kbSize.height);
//                [self.scrollView setContentOffset:scrollPoint animated:YES];
//            }else {
//                CGPoint scrollPoint = CGPointMake(0.0, origin.y + 118.5f - kbSize.height);
//                [self.scrollView setContentOffset:scrollPoint animated:YES];
//            }
//
//        }
//    }

}

- (void)keyboardWillHide:(NSNotification *)notification {
    // 键盘处理方法1
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    CGPoint point = self.scrollView.contentOffset;
    NSLog(@"keyboardWillHide  %@",NSStringFromCGPoint(point));
    // 动画收起键盘
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    
    
    // 键盘处理2
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//     self.scrollView.contentInset = contentInsets;
//     self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    
    // 获取第一次滑到最底的offsetY 防止scrollView.contentSize改变offsetY值获取不对
    if (!self.scrollViewOffy) {
        self.scrollViewOffy = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    CGFloat offHeight = 0;
    if (height != 0) {
        self.scrollViewBottomDistance.constant = height;
        self.totalPriceBottomDistance.constant = height;
        offHeight = self.scrollViewOffy + height;
    } else {
        CGFloat tmpHeight = self.scrollView.contentOffset.y;
        offHeight = tmpHeight;
        
        if (IS_IPHONE_X) {
            self.totalPriceBottomDistance.constant = 44.0f;
            self.scrollViewBottomDistance.constant = 44.0f;
        }else {
            self.scrollViewBottomDistance.constant = 0;
            self.totalPriceBottomDistance.constant = 0;
        }
        
    }
    [self.scrollView setContentOffset:CGPointMake(0, offHeight) animated:YES];
}
@end
