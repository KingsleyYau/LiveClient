//
//  LSSendScheduleViewController.m
//  livestream
//
//  Created by test on 2020/3/24.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSSendScheduleViewController.h"
#import "LSSessionRequestManager.h"
#import "LSGetEmfDetailRequest.h"
#import "LSOutOfCreditsView.h"
#import "LSOutOfPoststampView.h"
#import "LSGetSendMailPriceRequest.h"
#import "LSSendEmfRequest.h"
#import "LiveRoomCreditRebateManager.h"
#import "DialogTip.h"
#import "LSChatTextView.h"
#import "LSUserInfoManager.h"
#import "LSImageViewLoader.h"
#import "LSAddCreditsViewController.h"
#import "LSSendEmfRequest.h"
#import "LSPrepaidDateView.h"
#import "LSPrePaidPickerView.h"
#import "LSPrepaidInfoView.h"
#import "LSPurchaseCreditsView.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LSSendMailDraftManager.h"

#define maxCount 6000
typedef enum : NSUInteger {
    AlertViewTypeDefault = 0,      //默认无操作
    AlertViewTypeSendTip,          //发送二次确认提示
} AlertViewType;
@interface LSSendScheduleViewController ()<UIScrollViewDelegate, LSChatTextViewDelegate, LSOutOfPoststampViewDelegate, LSOutOfCreditsViewDelegate,UITextViewDelegate,LSPrepaidDateViewDelegate,LSPrePaidPickerViewDelegate,LSPurchaseCreditsViewDelegate,LSPrePaidManagerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat scrollViewOffy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomDistance;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
//买点弹窗
@property (nonatomic, strong) LSOutOfCreditsView *creditsView;
//邮票弹窗
@property (nonatomic, strong) LSOutOfPoststampView *poststampView;
// 是否花费邮票
@property (nonatomic, assign) BOOL isSpendStamp;
//发信需要的信用点
@property (nonatomic, assign) CGFloat credit;
//发信需要的邮票
@property (nonatomic, assign) NSInteger stamps;
@property (weak, nonatomic) IBOutlet LSChatTextView *mailTextView;
@property (weak, nonatomic) IBOutlet UIImageView *anchorPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *anchorOnlineStatus;
@property (weak, nonatomic) IBOutlet UILabel *anchorNameInfo;
@property (weak, nonatomic) IBOutlet UILabel *anchorLocalInfo;
@property (weak, nonatomic) IBOutlet UILabel *textCount;
@property (weak, nonatomic) IBOutlet LSPrepaidDateView *prepaidDateView;
@property (nonatomic, strong) LSPrePaidPickerView * pickerView;
// 是否显示键盘
@property (nonatomic, assign) BOOL isShowKeyBorad;
// 单击收起输入控件手势
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (weak, nonatomic) IBOutlet UIButton *howToWorkBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (nonatomic, strong) LSPurchaseCreditsView *purchaseCreditView;

/** 信件消息 */
@property (nonatomic, copy) NSString *replyMsg;
@property (nonatomic, strong) LSPrepaidInfoView * perpaidInfoView;
@property (nonatomic, assign) NSInteger selectedRow;//选中的国家
@property (nonatomic, assign) NSInteger selectedZoneRow;//选中的时区
@property (nonatomic, assign) NSInteger selectedDurationRow;//选中的时长
@property (nonatomic, assign) NSInteger selectedYearRow;//选中的日期
@property (nonatomic, assign) NSInteger selectedBeginTimeRow;//选中的开始时间
@end

@implementation LSSendScheduleViewController

- (void)dealloc {
    [[LSPrePaidManager manager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LSPrePaidManager manager] addDelegate:self];
    self.sessionManager = [LSSessionRequestManager manager];
    [LSSendMailDraftManager manager];
    self.scrollView.delegate = self;
    self.scrollView.userInteractionEnabled = YES;
    self.mailTextView.chatTextViewDelegate = self;
    self.mailTextView.delegate = self;
    self.mailTextView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xCACACA).CGColor;
    self.mailTextView.layer.borderWidth = 1;
    self.mailTextView.layer.cornerRadius = 4.0f;
    self.mailTextView.layer.masksToBounds = YES;
    
    NSString *howItWorkTitle = @"Learn how Schedule One-on-One works";
    NSMutableAttributedString *howItWorkTitleAtts = [[NSMutableAttributedString alloc] initWithString:howItWorkTitle attributes:@{
        NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],
        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x999999)
    }];
    [self.howToWorkBtn setAttributedTitle:howItWorkTitleAtts forState:UIControlStateNormal];
    self.howToWorkBtn.layer.cornerRadius = 22.0f;
    self.howToWorkBtn.layer.masksToBounds = YES;
    
    self.anchorOnlineStatus.layer.cornerRadius = self.anchorOnlineStatus.frame.size.width * 0.5f;
    self.anchorOnlineStatus.layer.masksToBounds = YES;
    
    self.sendBtn.layer.cornerRadius = 22.0f;
    self.sendBtn.layer.masksToBounds = YES;
    
    self.prepaidDateView.delegate = self;
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    

    [self setupScheduleInfo];
    [self setupUserInfo];

}


- (void)setupScheduleInfo {
    for (int i = 0; i < [LSPrePaidManager manager].countriesArray.count; i++) {
        LSCountryTimeZoneItemObject * item =[LSPrePaidManager manager].countriesArray[i];
        if (item.isDefault) {
            self.selectedRow = i;
            LSCountryTimeZoneItemObject * item = [[LSPrePaidManager manager].countriesArray objectAtIndex:self.selectedRow];
            [self.prepaidDateView updateCountries:item];
            break;
        }
    }
    
    for (int i = 0; i < [LSPrePaidManager manager].creditsArray.count; i++) {
        LSScheduleDurationItemObject * item = [LSPrePaidManager manager].creditsArray[i];
        if (item.isDefault) {
            self.selectedDurationRow = i;
            [self.prepaidDateView updateCredits:item];
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *content = [[LSSendMailDraftManager manager] getScheduleMailDraft:self.anchorId];
    self.textCount.text = [NSString stringWithFormat:@"%d", (int)(maxCount - content.length)];
    self.mailTextView.text = content;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.purchaseCreditView removeShowCreditView];
}

// 初始化预约没点弹层
- (void)setupPurchaseCreditView:(NSString *)photoUrl anchorName:(NSString *)anchorName{
    self.purchaseCreditView = [[LSPurchaseCreditsView alloc] init];
    self.purchaseCreditView.delegate = self;
    [self.purchaseCreditView setupCreditView:photoUrl];
}

- (void)showCreditView {
    [self.purchaseCreditView setupCreditTipIsAccept:NO name:self.anchorName credit:[LiveRoomCreditRebateManager creditRebateManager].mCredit];
    [self.purchaseCreditView showLSCreditViewInView:self.navigationController.view];
}

- (void)setupUserInfo {
    self.anchorPhoto.layer.cornerRadius = self.anchorPhoto.frame.size.width * 0.5f;
    self.anchorPhoto.layer.masksToBounds = YES;
    [[LSUserInfoManager manager] getUserInfoWithRequest:self.anchorId finishHandler:^(LSUserInfoModel *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (item) {
                // 头像
                [[LSImageViewLoader loader] loadImageFromCache:self.anchorPhoto
                                                       options:SDWebImageRefreshCached
                                                      imageUrl:item.photoUrl
                                              placeholderImage:LADYDEFAULTIMG
                                                 finishHandler:^(UIImage *image){
                                                 }];
                // 姓名

                NSString *title = [NSString stringWithFormat:@"%@ (ID:%@)",item.nickName,self.anchorId];
                NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
                                                                                                                       NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x666666),
                                                                                                                        NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                                                                                                    }];
                NSRange timeRange = [title rangeOfString:[NSString stringWithFormat:@"%@",item.nickName]];
                [atts addAttributes:@{
                                             NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x2A2A2A),
                                             NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                             } range:timeRange];
                self.anchorNameInfo.attributedText = atts;
                self.anchorLocalInfo.text = [NSString stringWithFormat:@"%dyrs / %@",item.age,item.country];
                self.anchorOnlineStatus.hidden = !item.isOnline;
                
                
                self.title = [NSString stringWithFormat:@"Schedule with %@",item.nickName];
                
                self.anchorName = item.nickName;
                
                [self setupPurchaseCreditView:item.photoUrl anchorName:item.nickName];
            }
        });
    }];
}



- (IBAction)sendMailAction:(id)sender {
    // 先判断是否输入文本内容
    if (self.mailTextView.text.length == 0 || [self isEmpty:self.mailTextView.text]) {
        [self showAlertViewMsg:NSLocalizedStringFromSelf(@"NO_MAIL_TEXT") cancelBtnMsg:nil otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeDefault];
        return;
    }
    // 先请求发信费用 再回件
    [self showAlertViewMsg:NSLocalizedStringFromSelf(@"SEND_MAIL_TIP") cancelBtnMsg:NSLocalizedString(@"Cancel", nil) otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeSendTip];

}


- (void)addCreditsBtnDid:(id)sender {
    // 跳转充值界面 保存草稿箱
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)howItWorkAction:(id)sender {
    self.perpaidInfoView = nil;
    [self.perpaidInfoView removeFromSuperview];
    self.perpaidInfoView = [[LSPrepaidInfoView alloc]init];
    [self.navigationController.view addSubview:self.perpaidInfoView];
}


#pragma mark - HTTP请求
- (void)getSendMailPrice {
    [self showLoading];
    WeakObject(self, weakSelf);
    LSGetSendMailPriceRequest *request = [[LSGetSendMailPriceRequest alloc] init];
    request.imgNumber = 0;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, double creditPrice, double stampPrice) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSendScheduleViewController::LSGetSendMailPriceRequest (获取发送信件所需余额 %@ errmsg: %@ errnum: %d creditPrice: %f stampPrice : %f)", BOOL2SUCCESS(success), errmsg, errnum, creditPrice, stampPrice);
            [weakSelf hideLoading];
            if (success) {
                weakSelf.credit = creditPrice;
                weakSelf.stamps = stampPrice;
                [self getCount];
            
            } else {
                [[DialogTip dialogTip] showDialogTip:weakSelf.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getCount {
    [self showLoading];
    WeakObject(self, weakSelf);
    [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                if (postStamp >= weakSelf.stamps) {
                    weakSelf.isSpendStamp = YES;
                }else {
                    weakSelf.isSpendStamp = NO;
                }
                [weakSelf sendMail];
            } else {
                NSLog(@"LSAddCreditsViewController::LeftCredit( 获取男士余额失败");
                [[DialogTip dialogTip] showDialogTip:weakSelf.view tipText:errmsg];
            }
        });
    }];
}


- (void)sendMail {
    [self showLoading];
    WeakObject(self, weakSelf);
    LSSendEmfRequest *request = [[LSSendEmfRequest alloc] init];
    request.content = self.mailTextView.text;
    request.isSchedule = YES;
    request.timeZoneId = [LSPrePaidManager manager].zoneItem.zoneId;
    request.startTime = [[LSPrePaidManager manager]getSendRequestTime:@"yyyy-MM-dd HH:00:00"];;
    request.duration = [[LSPrePaidManager manager].duration intValue];
    request.anchorId = self.anchorId;
    if (self.isSpendStamp) {
        request.comsumeType = LSLETTERCOMSUMETYPE_STAMP;
    } else {
        request.comsumeType = LSLETTERCOMSUMETYPE_CREDIT;
    }
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *  errmsg, NSString *  emfId) {
        NSLog(@"LSSendScheduleViewController::sendMail (发送信件 %@ errmsg: %@ errnum: %d)", BOOL2SUCCESS(success), errmsg, errnum);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideLoading];
            if (success) {
                [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg){
                    
                }];
                [[LSSendMailDraftManager manager] deleteScheduleMailDraft:self.anchorId];
                NSURL *outBoxDetailUrl = [[LiveUrlHandler shareInstance] createScheduleMailDetail:emfId anchorName:self.anchorName type:LiveUrlScheduleMailDetailTypeOutBox];
                
                [[LiveModule module].serviceManager handleOpenURL:outBoxDetailUrl];
                
            } else {
                if (errnum == HTTP_LCC_ERR_LETTER_NO_CREDIT_OR_NO_STAMP) {
                       // 发送预付费直播:男士信用点不足
                    [self showCreditView];
                }else if (errnum == HTTP_LCC_ERR_SCHEDULE_ANCHOR_NO_PRIV){
                       // 发送预付费直播:主播无权限
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"UNAVAILABLE")];
                }else if (errnum == HTTP_LCC_ERR_SCHEDULE_NOTENOUGH_OR_OVER_TIEM){
                       // 发送预付费直播:开始时间离现在不足24小时或超过14天
                    [[LSPrePaidManager manager]getDateData];
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"OUT_OF_TIME")];
                }else if (errnum == HTTP_LCC_ERR_SCHEDULE_NO_CREDIT){
                       // 发送预付费直播:男士信用点不足
                    [self showCreditView];
                } else {
                    [weakSelf showAlertViewMsg:errmsg cancelBtnMsg:nil otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeDefault];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)onRecvScheduleGetDateData {
    [self.prepaidDateView updateNewBeginTime];
}
#pragma mark - AlertView回调
- (void)showAlertViewMsg:(NSString *)titleMsg cancelBtnMsg:(NSString *)cancelMsg otherBtnMsg:(NSString *)otherMsg alertViewType:(AlertViewType)type{
    [self.view endEditing:YES];
    if (self.isShowKeyBorad) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.56 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:titleMsg preferredStyle:UIAlertControllerStyleAlert];
            if (cancelMsg.length > 0) {
                UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:cancelMsg style:UIAlertActionStyleCancel handler:nil];
                [alertVC addAction:cancelAC];
            }
            if (otherMsg.length > 0) {
                UIAlertAction *otherAC = [UIAlertAction actionWithTitle:otherMsg style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self alertViewClickOtherAction:type];
                }];
                [alertVC addAction:otherAC];
            }
            [self presentViewController:alertVC animated:YES completion:nil];
        });
    } else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:titleMsg preferredStyle:UIAlertControllerStyleAlert];
        if (cancelMsg.length > 0) {
            UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:cancelMsg style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:cancelAC];
        }
        if (otherMsg.length > 0) {
            UIAlertAction *otherAC = [UIAlertAction actionWithTitle:otherMsg style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self alertViewClickOtherAction:type];
            }];
            [alertVC addAction:otherAC];
        }
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)alertViewClickOtherAction:(AlertViewType)type {
    switch (type) {
        case AlertViewTypeSendTip:{
            [self getSendMailPrice];
        }break;
            
        default:
            break;
    }
}
#pragma mark - 输入控件管理
- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllInputView)];
        [self.scrollView addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.scrollView removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

#pragma mark - 关闭所有输入控件
- (void)closeAllInputView {
    // 降低加速度
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    // 移除手势
    [self removeSingleTap];
    // 关闭系统键盘
    [self.mailTextView resignFirstResponder];
}

- (void)hiddenKeyBroad {
    if (self.isShowKeyBorad) {
        [self closeAllInputView];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (![self.mailTextView isEqual:scrollView]) {
        [self hiddenKeyBroad];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    // 超过字符限制
    NSString *toBeString = textView.text;
    // 获取是否存在高亮部分
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if (toBeString.length > maxCount) {
            textView.text = [textView.text substringToIndex:maxCount];
            self.textCount.text = @"0";
        }else {
            self.textCount.text = [NSString stringWithFormat:@"%d", (int)(maxCount - toBeString.length)];
        }
    }
    [[LSSendMailDraftManager manager] saveScheduleMailDraftFromLady:self.anchorId content:textView.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

        self.replyMsg = textView.text;
        int count  = (int)(maxCount - textView.text.length);
    
        if (count >= 0) {
            self.textCount.text = [NSString stringWithFormat:@"%d", count];
        }else {
            self.textCount.text = @"0";
            // 判断是否删除字符
            if ('\000' != [text UTF8String][0] && ![text isEqualToString:@"\b"]) {
                // 非删除字符，不允许输入
                return  NO;
            }
        }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // 增加手势
    [self addSingleTap];
    return YES;
}

- (void)purchaseDidAction {
    [self.purchaseCreditView removeShowCreditView];
    [self addCreditsBtnDid:nil];
}

#pragma mark -KeyboardNSNotification
- (void)keyboardDidShow:(NSNotification *)notification {
    self.isShowKeyBorad = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    self.isShowKeyBorad = NO;
}

- (void)keyboardWillShow:(NSNotification *)notification {

    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
//    CGRect aRect = self.scrollView.frame;
//    aRect.size.height -= kbSize.height;
    CGPoint origin = [self.mailTextView convertPoint:CGPointZero toView:self.scrollView];
//    if (!CGRectContainsPoint(aRect, origin) ) {
//        CGPoint scrollPoint = CGPointMake(0.0, origin.y + 30 - kbSize.height);
        CGPoint scrollPoint = CGPointMake(0.0, origin.y - self.mailTextView.frame.size.height + 35);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
//    }
    
    

}

- (void)keyboardWillHide:(NSNotification *)notification {
    // 键盘处理方法1
//    NSDictionary *userInfo = [notification userInfo];
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    CGPoint point = self.scrollView.contentOffset;
//    NSLog(@"keyboardWillHide  %@",NSStringFromCGPoint(point));
//    // 动画收起键盘
//    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    
    
  
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    
    // 获取第一次滑到最底的offsetY 防止scrollView.contentSize改变offsetY值获取不对
    if (!self.scrollViewOffy) {
        self.scrollViewOffy = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    CGFloat offHeight = 0;
    if (height != 0) {
        self.scrollViewBottomDistance.constant = height;
   
        offHeight = self.scrollViewOffy + height;
    } else {
        CGFloat tmpHeight = self.scrollView.contentOffset.y;
        offHeight = tmpHeight;
        
//        if (IS_IPHONE_X) {
//            self.scrollViewBottomDistance.constant = 44.0f;
//        }else {
            self.scrollViewBottomDistance.constant = 0;
//        }
        
    }
    [self.scrollView setContentOffset:CGPointMake(0, offHeight) animated:YES];
}

-(BOOL)isEmpty:(NSString *) str {
    NSCharacterSet*set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString*trimedString = [str stringByTrimmingCharactersInSet:set];
    if([trimedString length] ==0) {
        return YES;
    }else{
        return NO;
    }
}


#pragma mark - prepaidDateView
- (void)prepaidDateViewBtnDid:(UIButton*)button {
    
    self.pickerView = [[LSPrePaidPickerView alloc]init];
    self.pickerView.delegate = self;
    [self.view.window addSubview:self.pickerView];
    self.pickerView.selectTimeRow = [self getSelectedRow:button];
    self.pickerView.items = [self getPickerData:button];
    [self.pickerView reloadData];
}

- (void)pickerViewSelectedRow:(NSInteger)row {
    if (self.prepaidDateView.countriesButton.isSelected) {
        self.prepaidDateView.countriesButton.selected = NO;
    
        self.selectedRow = row;
        LSCountryTimeZoneItemObject * item = [[LSPrePaidManager manager].countriesArray objectAtIndex:row];
        [self.prepaidDateView updateCountries:item];
        [self.prepaidDateView updateTimeZone:[item.timeZoneList firstObject]];
        
    }else if (self.prepaidDateView.timeZoneButton.isSelected) {
        self.prepaidDateView.timeZoneButton.selected = NO;
        
         LSCountryTimeZoneItemObject * item = [[LSPrePaidManager manager].countriesArray objectAtIndex:self.selectedRow];
        
        LSTimeZoneItemObject * tiemItem = [item.timeZoneList objectAtIndex:row];
        self.selectedZoneRow = row;
        [self.prepaidDateView updateTimeZone:tiemItem];
    }else if (self.prepaidDateView.creditsButton.isSelected) {
        self.prepaidDateView.creditsButton.selected = NO;
        LSScheduleDurationItemObject * item = [[LSPrePaidManager manager].creditsArray objectAtIndex:row];
        self.selectedDurationRow = row;
        [self.prepaidDateView updateCredits:item];
    }
    else if (self.prepaidDateView.timeButton.isSelected) {
        self.prepaidDateView.timeButton.selected = NO;
        self.selectedYearRow = row;
        [self.prepaidDateView updateDate:[[[LSPrePaidManager manager]getYearArray] objectAtIndex:row]];
 
        
    }else if (self.prepaidDateView.beginTimeButton.isSelected) {
        self.prepaidDateView.beginTimeButton.selected = NO;
        self.selectedBeginTimeRow = row;
        NSArray * array = [[LSPrePaidManager manager]getTimeArray];
        [self.prepaidDateView updateBeginTime:[array objectAtIndex:row]];
    }
}

- (NSInteger)getSelectedRow:(UIButton *)button {
    if ([button isEqual:self.prepaidDateView.countriesButton]) {
       return self.selectedRow;
    }else if ([button isEqual:self.prepaidDateView.timeZoneButton]) {
        return self.selectedZoneRow;
    }else if ([button isEqual:self.prepaidDateView.creditsButton]) {
        return self.selectedDurationRow;
    }else if ([button isEqual:self.prepaidDateView.timeButton]) {
        self.selectedYearRow = [[[LSPrePaidManager manager]getYearArray] indexOfObject:button.titleLabel.text];
       return self.selectedYearRow;
    }else if ([button isEqual:self.prepaidDateView.beginTimeButton]) {
         self.selectedBeginTimeRow = [[[LSPrePaidManager manager]getTimeArray] indexOfObject:button.titleLabel.text];
       return self.selectedBeginTimeRow;
    }
    return 0;
}

- (NSArray *)getPickerData:(UIButton *)button {
    button.selected = YES;
    if ([button isEqual:self.prepaidDateView.countriesButton]) {
       NSMutableArray * array = [NSMutableArray array];
        for (LSCountryTimeZoneItemObject * item in [LSPrePaidManager manager].countriesArray) {
            [array addObject:item.countryName];
        }
        return array;
    }
    else if ([button isEqual:self.prepaidDateView.timeZoneButton]) {
        NSMutableArray * array = [NSMutableArray array];
        LSCountryTimeZoneItemObject * item = [[LSPrePaidManager manager].countriesArray objectAtIndex:self.selectedRow];
        for (LSTimeZoneItemObject * timeItem in item.timeZoneList) {
            [array addObject:[[LSPrePaidManager manager] getTimeZoneText:timeItem]];
        }
        return array;
    }
    else if ([button isEqual:self.prepaidDateView.creditsButton]) {
        return [[LSPrePaidManager manager] getCreditArray];
    }else if ([button isEqual:self.prepaidDateView.timeButton]) {
         return [[LSPrePaidManager manager]getYearArray];
    }else if ([button isEqual:self.prepaidDateView.beginTimeButton]) {
        return [[LSPrePaidManager manager]getTimeArray];
    }
    return @[];
}


- (void)removePrePaidPickerView {
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
    [self.prepaidDateView resetBtnState];
}

- (void)prepaidPickerViewSelectedRow:(NSInteger)row {
 
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
    [self pickerViewSelectedRow:row];
}


@end
