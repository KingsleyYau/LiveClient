//
//  LSGreetingDetailViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/11/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSGreetingDetailViewController.h"
#import "LSMailAttachmentViewController.h"
#import "LSAddCreditsViewController.h"
#import "LSSendMailViewController.h"
#import "AnchorPersonalViewController.h"

#import <YYText.h>
#import "IntroduceView.h"
#import "LSChatTextView.h"
#import "LSOutOfCreditsView.h"
#import "LSOutOfPoststampView.h"
#import "DialogTip.h"
#import "LSGreetingsDetailTableViewCell.h"
#import "LSShadowView.h"

#import "LSSessionRequestManager.h"
#import "LSGetLoiDetailRequest.h"
#import "LSSendEmfRequest.h"
#import "LSGetSendMailPriceRequest.h"
#import "LSAnchorLetterPrivRequest.h"

#import "LSLoginManager.h"
#import "LiveRoomCreditRebateManager.h"

#import "LSMailAttachmentModel.h"
#import "LiveModule.h"
#import "LSMailCellHeightItem.h"

#import "LSImageViewLoader.h"
#import "LSDateTool.h"
#import "LSSendMailDraftManager.h"
#import "LSUserInfoManager.h"

#define TABLEVIEWTOP 14
#define CONTENTVIDEOHEIGHT 256
#define CONTENTIMAGEHEIGHT 232
#define ReplyViewHeight 325
#define MAXInputCount 6000

#define TAP_HERE_URL @"TAP_HERE_URL"

typedef enum : NSUInteger {
    AlertViewTypeDefault = 0,      //默认无操作
    AlertViewTypeBack,             //返回草稿
    AlertViewTypeSendTip,          //发送二次确认提示
    AlertViewTypeSendSuccessfully, //发送成功
    AlertViewTypeNoSendPermissions //没有发信权限
} AlertViewType;

@interface LSGreetingDetailViewController () <WKNavigationDelegate, WKUIDelegate, LSMailAttachmentViewControllerDelegate, UITextViewDelegate, UIScrollViewDelegate, LSChatTextViewDelegate, LSOutOfPoststampViewDelegate, LSOutOfCreditsViewDelegate, UITableViewDelegate, UITableViewDataSource, LSGreetingsDetailTableViewCellDelegate, LSSendMailViewControllerDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
// 头像
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImageView;
// 在线图片
@property (weak, nonatomic) IBOutlet UIImageView *onlineImageView;
// 寄件人姓名
@property (weak, nonatomic) IBOutlet UILabel *fromeNameLabel;
// 寄件时间
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
// 回复按钮
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
// 文本容器
@property (weak, nonatomic) IBOutlet UIView *contentView;
// 加载html样式
@property (weak, nonatomic) IBOutlet IntroduceView *wkWebView;
// 新建文字内容高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
// 内容列表
@property (weak, nonatomic) IBOutlet LSTableView *tableView;
// 内容列表高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
// 内容列表顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop;
// 邮件ID
@property (weak, nonatomic) IBOutlet UILabel *mailIdLabel;
// 回复view
@property (weak, nonatomic) IBOutlet LSChatTextView *replyTextView;
// textview阴影
@property (weak, nonatomic) IBOutlet UIView *textShadowView;
// 文本提示
@property (weak, nonatomic) IBOutlet YYLabel *infoTipLabel;
// 回复按钮
@property (weak, nonatomic) IBOutlet UIButton *replySendBtn;
// 回复界面底部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyViewBottom;
// 回复界面底部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyViewHeight;
// 无数据遮挡view
@property (weak, nonatomic) IBOutlet UIView *nodataView;

// 数据源
@property (strong, nonatomic) NSMutableArray<LSMailAttachmentModel *> *items;
// cell高度数组
@property (strong, nonatomic) NSMutableArray<LSMailCellHeightItem *> *heightItems;
// 单击收起输入控件手势
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
// 是否显示键盘
@property (nonatomic, assign) BOOL isShowKeyBorad;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 是否花费邮票
@property (nonatomic, assign) BOOL isSpendStamp;
// 发信底部提示语
@property (nonatomic, copy) NSString *infoStr;
// 草稿箱初始化文本
@property (nonatomic, copy) NSString *quickReplyStr;
//发信需要的信用点
@property (nonatomic, assign) CGFloat credit;
//发信需要的邮票
@property (nonatomic, assign) CGFloat stamps;
//买点弹窗
@property (nonatomic, strong) LSOutOfCreditsView *creditsView;
//邮票弹窗
@property (nonatomic, strong) LSOutOfPoststampView *poststampView;

@property (nonatomic, assign) CGFloat scrollViewOffy;
@end

@implementation LSGreetingDetailViewController

- (void)dealloc {
    NSLog(@"LSGreetingDetailViewController::dealloc()");

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initCustomParam {
    [super initCustomParam];

    self.isShowKeyBorad = NO;
    self.isSpendStamp = NO;

    self.scrollViewOffy = 0;

    self.items = [[NSMutableArray alloc] init];
    self.heightItems = [[NSMutableArray alloc] init];

    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedStringFromSelf(@"TITLE");

    // 系统返回按钮样式
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(backToAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"Navigation_Back_Button"] forState:UIControlStateNormal];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftButtonItem;

    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;

    self.scrollView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    // 默认隐藏内容列表
    self.tableViewHeight.constant = 0;
    self.tableViewTop.constant = 0;
    self.tableView.scrollEnabled = NO;
    self.tableView.bounces = NO;

    [self setupTapLabelStyle];

    [self setupCornerRadius];

    [self setupTextView];

    self.wkWebView.scrollView.scrollEnabled = NO;

    if (self.letterItem.anchorAvatar.length > 0) {
        // 头像
        [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                               options:SDWebImageRefreshCached
                                              imageUrl:self.letterItem.anchorAvatar
                                      placeholderImage:LADYDEFAULTIMG
                                         finishHandler:^(UIImage *image){
                                         }];
    }
    
    // 姓名
    if (self.letterItem.anchorNickName.length > 0) {
        self.fromeNameLabel.text = self.letterItem.anchorNickName;
    }
    
    if (self.letterItem.letterSendTime > 0) {
        // 发信时间
        LSDateTool *tool = [[LSDateTool alloc] init];
        self.timeLabel.text = [tool showGreetingDetailTimeOfDate:[NSDate dateWithTimeIntervalSince1970:self.letterItem.letterSendTime]];
    }
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.viewDidAppearEver) {
        if ([LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailPriv) {
            if (self.letterItem.anchorId.length > 0) {
                [self getAnchorLetterPriv:self.letterItem.anchorId];
            }
        } else {
            if (self.letterItem.letterId.length > 0) {
                [self getLoiDetail:self.letterItem.letterId];
            }
        }
    }

    // 初始化草稿管理器
    [[LSSendMailDraftManager manager] initMailDraftLadyId:self.letterItem.anchorId name:self.letterItem.anchorNickName];
    self.quickReplyStr = [[LSSendMailDraftManager manager] getDraftContent:self.letterItem.anchorId];
    [self.replyTextView setText:self.quickReplyStr];
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

#pragma mark - 界面初始化
- (void)setupCornerRadius {
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.borderWidth = 1;
    self.headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headImageView.layer.masksToBounds = YES;

    self.onlineImageView.layer.cornerRadius = self.onlineImageView.frame.size.height / 2;
    self.onlineImageView.layer.borderWidth = 2;
    self.onlineImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.onlineImageView.layer.masksToBounds = YES;

    self.replyBtn.layer.cornerRadius = self.replyBtn.frame.size.height / 2;
    self.replyBtn.layer.masksToBounds = YES;

    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;

    self.replySendBtn.layer.cornerRadius = 5;
    self.replySendBtn.layer.masksToBounds = YES;

    LSShadowView *shadowView = [[LSShadowView alloc] init];
    [shadowView showShadowAddView:self.replySendBtn];
}

- (void)setupTextView {
    self.replyTextView.placeholder = NSLocalizedStringFromSelf(@"TYPE_YOUR_MSG");
    self.replyTextView.chatTextViewDelegate = self;
    self.replyTextView.delegate = self;

    self.textShadowView.layer.cornerRadius = 5;
    self.textShadowView.clipsToBounds = NO;
    self.textShadowView.layer.shadowColor = Color(162, 180, 206, 1).CGColor;
    self.textShadowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.textShadowView.layer.shadowOpacity = 0.5;
    self.textShadowView.layer.shadowRadius = 1;
    self.textShadowView.layer.masksToBounds = NO;

    self.replyTextView.layer.cornerRadius = 5;
    self.replyTextView.layer.masksToBounds = YES;
}

- (void)setupTapLabelStyle {

    // 信用點及郵票都沒有，或者有超過1個郵票或以上，默認使用郵票，如果沒有郵票有信用點默認使用信用點。
    if ([LiveRoomCreditRebateManager creditRebateManager].mPostStamp >= 1 || ([LiveRoomCreditRebateManager creditRebateManager].mCredit <= 0 && [LiveRoomCreditRebateManager creditRebateManager].mPostStamp < 1)) {
        self.isSpendStamp = YES;
        self.infoStr = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.quickPostStampMsg;
    } else {
        self.isSpendStamp = NO;
        self.infoStr = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.quickCoinMsg;
    }

    //没有发信权限(隐藏快捷回复)
    if (![LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailPriv) {
        self.replyViewHeight.constant = 0;
        [self.view layoutSubviews];
    }

    // 邮票提示
    [self setupInfoTip];
    [self setupInfoTipLabel];
}

#pragma mark - 设置底部信息UI
- (void)setupInfoTip {
    self.infoTipLabel.numberOfLines = 0;
    self.infoTipLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 40;
    self.infoTipLabel.font = [UIFont systemFontOfSize:12];
    self.infoTipLabel.displaysAsynchronously = NO;

    WeakObject(self, weakSelf);
    [self.infoTipLabel setHighlightTapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
        YYTextHighlight *highlight = [text yy_attribute:YYTextHighlightAttributeName atIndex:range.location];
        NSString *link = highlight.userInfo[@"linkUrl"];
        if ([link isEqualToString:TAP_HERE_URL]) {
            weakSelf.isSpendStamp = !weakSelf.isSpendStamp;
            [weakSelf setupInfoTipLabel];
        }
    }];
}

- (void)setupInfoTipLabel {
    //TODO: 判断是否有邮票
    if (self.isSpendStamp) {
        self.infoStr = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.quickPostStampMsg;
    } else {
        self.infoStr = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.quickCoinMsg;
    }
    NSString *titleString = [NSString stringWithFormat:@"<font face=\"arialMT\" color=\"#999999\">%@</font>", self.infoStr];
    if (titleString.length > 0) {
        //创建  NSMutableAttributedString 富文本对象
        NSMutableAttributedString *maTitleString = [[NSMutableAttributedString alloc] initWithData:[titleString dataUsingEncoding:NSUnicodeStringEncoding]
                                                                                           options:@{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                                                                                                      NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                                                           }
                                                                                documentAttributes:nil
                                                                                             error:nil];
        UIImage *image = [UIImage imageNamed:@"Mail_Reply_Tip_Button"];
        //添加到富文本对象里
        NSMutableAttributedString *imageStr = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:[UIFont systemFontOfSize:12] alignment:YYTextVerticalAlignmentCenter];
        //加入文字后面
        [maTitleString appendAttributedString:imageStr];

        YYTextHighlight *highlight = [YYTextHighlight new];
        NSRange imgRange = [maTitleString.string rangeOfString:imageStr.string];
        highlight.userInfo = @{ @"linkUrl" : TAP_HERE_URL };
        [maTitleString yy_setTextHighlight:highlight range:imgRange];

        YYTextContainer *container = [[YYTextContainer alloc] init];
        container.size = CGSizeMake(SCREEN_WIDTH - 40, 56);
        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:maTitleString];
        self.infoTipLabel.textLayout = layout;

        //        self.infoTipLabel.attributedText = maTitleString;
    }
}

#pragma mark - 显示意向信文本内容
- (void)loadMailContentWebView:(NSString *)contentStr {
    NSString *path = [[LiveBundle mainBundle] pathForResource:@"Mail_Content" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    NSRange startRange = [html rangeOfString:@"<div class=\"content\">"];
    NSRange endRange = [html rangeOfString:@"</div>"];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    NSString *result = [html substringWithRange:range];
    NSString *tempContent = [html stringByReplacingOccurrencesOfString:result withString:contentStr];

    NSURL *url = [[LiveBundle mainBundle] URLForResource:@"Mail_Content.html" withExtension:nil];
    [self.wkWebView loadHTMLString:tempContent baseURL:url];
}

#pragma mark - 邮票/余额 弹窗
- (void)showStampsView {
    [self.poststampView removeFromSuperview];
    self.poststampView = nil;
    [self.creditsView removeFromSuperview];
    self.creditsView = nil;
    self.poststampView = [LSOutOfPoststampView initWithActionViewDelegate:self];
    [self.poststampView outOfPoststampShowCreditView:self.view balanceCount:[NSString stringWithFormat:@"Send by Credits (%0.1f credits)", self.credit]];
}

- (void)lsOutOfPoststampView:(LSOutOfPoststampView *)addView didSelectAddCredit:(UIButton *)creditBtn {

    if (self.credit > [LiveRoomCreditRebateManager creditRebateManager].mCredit) {
        //余额不足
        [self addCreditsBtnDid:nil];
    } else {
        self.isSpendStamp = NO;
        [self setupInfoTipLabel];
        [self sendMail];
    }
}

- (void)showCreditsView {
    [self.creditsView removeFromSuperview];
    self.creditsView = nil;
    [self.poststampView removeFromSuperview];
    self.poststampView = nil;
    self.creditsView = [LSOutOfCreditsView initWithActionViewDelegate:self];
    [self.creditsView outOfCreditShowPoststampAndAddCreditView:self.view poststampCount:[NSString stringWithFormat:@"%ld", (long)self.stamps]];
}

- (void)lsOutOfCreditsView:(LSOutOfCreditsView *)addView didSelectAddCredit:(UIButton *)creditBtn {
    [self addCreditsBtnDid:nil];
}

- (void)lsOutOfCreditsView:(LSOutOfCreditsView *)addView didSelectSendPoststamp:(UIButton *)SendPoststampBtn {
    self.isSpendStamp = YES;
    [self setupInfoTipLabel];
    [self sendMail];
}

#pragma mark - AlertView回调
- (void)showAlertViewMsg:(NSString *)titleMsg cancelBtnMsg:(NSString *)cancelMsg otherBtnMsg:(NSString *)otherMsg alertViewType:(AlertViewType)type {
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
                    [self alertView:type clickCancleOrOther:1];
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
                [self alertView:type clickCancleOrOther:1];
            }];
            [alertVC addAction:otherAC];
        }
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)alertView:(NSInteger)tag clickCancleOrOther:(NSInteger)index {
    switch (tag) {
        case AlertViewTypeBack: { //返回弹窗
            if (index == 0) {
                //Save Draft
                [[LSSendMailDraftManager manager] saveMailDraftFromLady:self.letterItem.anchorId content:self.replyTextView.text];
                [self.navigationController popViewControllerAnimated:YES];
            } else if (index == 1) {
                //Delete Draft
                [[LSSendMailDraftManager manager] deleteMailDraft:self.letterItem.anchorId];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } break;
        case AlertViewTypeSendTip: { //发送二次确认提示
            if (index != 0) {
                [[LiveModule module].analyticsManager reportActionEvent:ReplyMailConfirmSendMail eventCategory:EventCategoryMail];
                // 先请求发信费用 再回件
                [self getSendMailPrice];
            }
        } break;
        case AlertViewTypeSendSuccessfully: { //发送成功
            [self.navigationController popViewControllerAnimated:YES];
        } break;
        case AlertViewTypeNoSendPermissions: { //没有发信权限
            [self.navigationController popViewControllerAnimated:YES];
        } break;
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
    [self.replyTextView resignFirstResponder];
}

#pragma mark - HTTP请求
- (void)getSendMailPrice {
    [self showLoading];
    WeakObject(self, weakSelf);
    LSGetSendMailPriceRequest *request = [[LSGetSendMailPriceRequest alloc] init];
    request.imgNumber = 0;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, double creditPrice, double stampPrice) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSGreetingDetailViewController::LSGetSendMailPriceRequest (获取发送信件所需余额 %@ errmsg: %@ errnum: %d creditPrice: %f stampPrice : %f)", BOOL2SUCCESS(success), errmsg, errnum, creditPrice, stampPrice);
            [weakSelf hideLoading];
            if (success) {
                weakSelf.credit = creditPrice;
                weakSelf.stamps = stampPrice;
                [weakSelf sendMail];
            } else {
                [[DialogTip dialogTip] showDialogTip:weakSelf.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)sendMail {
    // 快捷回复
    [self showLoading];
    WeakObject(self, weakSelf);
    LSSendEmfRequest *request = [[LSSendEmfRequest alloc] init];
    request.anchorId = self.letterItem.anchorId;
    request.loiId = self.letterItem.letterId;
    request.content = self.replyTextView.text;
    if (self.isSpendStamp) {
        request.comsumeType = LSLETTERCOMSUMETYPE_STAMP;
    } else {
        request.comsumeType = LSLETTERCOMSUMETYPE_CREDIT;
    }
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *emfId) {
        NSLog(@"LSGreetingDetailViewController::sendMail (发送信件 %@ errmsg: %@ errnum: %d)", BOOL2SUCCESS(success), errmsg, errnum);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideLoading];
            if (success) {
                // 更新状态已回复
                weakSelf.letterItem.hasReplied = YES;
                if ([weakSelf.greetingDetailDelegate respondsToSelector:@selector(lsGreetingDetailViewController:haveReplyGreetingDetailMail:index:)]) {
                    [weakSelf.greetingDetailDelegate lsGreetingDetailViewController:weakSelf haveReplyGreetingDetailMail:weakSelf.letterItem index:weakSelf.greetingMailIndex];
                }

                [weakSelf showAlertViewMsg:NSLocalizedStringFromSelf(@"SEND_MAIL_SUCCESSFULLY") cancelBtnMsg:NSLocalizedString(@"OK", nil) otherBtnMsg:nil alertViewType:AlertViewTypeSendSuccessfully];
                [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg){

                }];
                [[LSSendMailDraftManager manager] deleteMailDraft:weakSelf.letterItem.anchorId];
                [[LSSendMailDraftManager manager] initMailDraftLadyId:weakSelf.letterItem.anchorId name:weakSelf.letterItem.anchorNickName];
                weakSelf.quickReplyStr = [[LSSendMailDraftManager manager] getDraftContent:weakSelf.letterItem.anchorId];
                [weakSelf.replyTextView setText:weakSelf.quickReplyStr];
                
            } else {
                if (errnum == HTTP_LCC_ERR_LETTER_NO_CREDIT_OR_NO_STAMP) {
                    if (weakSelf.isSpendStamp) {
                        //显示邮票弹窗
                        [weakSelf showStampsView];
                    } else {
                        //显示余额弹窗
                        [weakSelf showCreditsView];
                    }
                } else {
                    [weakSelf showAlertViewMsg:errmsg cancelBtnMsg:nil otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeDefault];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getAnchorLetterPriv:(NSString *)anchorId {
    [self showLoading];
    WeakObject(self, weakSelf);
    LSAnchorLetterPrivRequest *request = [[LSAnchorLetterPrivRequest alloc] init];
    request.anchorId = anchorId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSAnchorLetterPrivItemObject *item) {
        NSLog(@"LSGreetingDetailViewController::LSAnchorLetterPrivRequest ([获取主播信件权限 success : %@, errnum : %d, errmsg : %@, userCanSend : %d, anchorCanSend : %d])", BOOL2SUCCESS(success), errnum, errmsg, item.userCanSend, item.anchorCanSend);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                if (!item.anchorCanSend) {
                    weakSelf.replyViewHeight.constant = 0;
                    [weakSelf.view layoutSubviews];
                }
                // 获取权限成功 请求信件详情
                if (weakSelf.letterItem.letterId.length > 0) {
                    [weakSelf getLoiDetail:weakSelf.letterItem.letterId];
                }
            } else {
                [weakSelf hideLoading];
                [[DialogTip dialogTip] showDialogTip:weakSelf.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getLoiDetail:(NSString *)loiId {
    [self showAndResetLoading];
    WeakObject(self, weakSelf);
    LSGetLoiDetailRequest *request = [[LSGetLoiDetailRequest alloc] init];
    request.loiId = loiId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSHttpLetterDetailItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSGreetingDetailViewController::LSGetLoiDetailRequest (请求意向信详情 success : %@, errnum : %d, errmsg : %@, letterId : %@, hasReplied : %d)", BOOL2SUCCESS(success), errnum, errmsg, item.letterId, item.hasReplied);
            [weakSelf hideAndResetLoading];
            if (success) {
                if (!(weakSelf.letterItem.anchorNickName.length > 0)) {
                    weakSelf.fromeNameLabel.text = item.anchorNickName;
                }
                if (!(weakSelf.letterItem.anchorAvatar.length > 0)) {
                    [[LSImageViewLoader loader] loadImageFromCache:weakSelf.headImageView
                                                           options:SDWebImageRefreshCached
                                                          imageUrl:item.anchorAvatar
                                                  placeholderImage:LADYDEFAULTIMG
                                                     finishHandler:^(UIImage *image){
                                                     }];
                }
                
                [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg){

                }];
                // 更新发现时间
                if (!(weakSelf.letterItem.letterSendTime > 0)) {
                    LSDateTool *tool = [[LSDateTool alloc] init];
                    weakSelf.timeLabel.text = [tool showGreetingDetailTimeOfDate:[NSDate dateWithTimeIntervalSince1970:item.letterSendTime]];
                }
                
                // 显示意向信内容
                [weakSelf setupGreetingDetail:item];
                // 设置已读
                weakSelf.letterItem.hasRead = YES;
                // 刷新列表已读信息
                if ([weakSelf.greetingDetailDelegate respondsToSelector:@selector(lsGreetingDetailViewController:haveReadGreetingDetailMail:index:)]) {
                    [weakSelf.greetingDetailDelegate lsGreetingDetailViewController:weakSelf haveReadGreetingDetailMail:weakSelf.letterItem index:weakSelf.greetingMailIndex];
                }
            } else {
                [[DialogTip dialogTip] showDialogTip:weakSelf.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)setupGreetingDetail:(LSHttpLetterDetailItemObject *)item {
    [self.items removeAllObjects];
    [self.heightItems removeAllObjects];

    self.tableViewHeight.constant = 0;
    self.nodataView.hidden = YES;

    // 在线状态
    if (item.onlineStatus) {
        self.onlineImageView.hidden = NO;
    } else {
        self.onlineImageView.hidden = YES;
    }
    // 信件内容
    NSString *contentStr = [item.letterContent stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    [self loadMailContentWebView:contentStr];
    // 信件id
    self.mailIdLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"MAIL_ID"), item.letterId];

    if (item.letterVideoList.count > 0) {
        for (LSHttpLetterVideoItemObject *obj in item.letterVideoList) {
            LSMailAttachmentModel *model = [[LSMailAttachmentModel alloc] init];
            model.mailId = item.letterId;
            model.isReplied = item.hasReplied;
            model.attachType = AttachmentTypeGreetingVideo;
            model.videoUrl = obj.video;
            model.videoCoverUrl = obj.coverOriginImg;
            model.videoTime = obj.videoTotalTime;
            [self.items addObject:model];

            LSMailCellHeightItem *heightItem = [[LSMailCellHeightItem alloc] init];
            heightItem.mailId = item.letterId;
            heightItem.attachType = AttachmentTypeGreetingVideo;
            heightItem.url = obj.coverOriginImg;
            heightItem.height = CONTENTVIDEOHEIGHT;
            [self.heightItems addObject:heightItem];
        }
    }

    if (item.letterImgList.count > 0) {
        for (LSHttpLetterImgItemObject *obj in item.letterImgList) {
            LSMailAttachmentModel *model = [[LSMailAttachmentModel alloc] init];
            model.mailId = item.letterId;
            model.isReplied = item.hasReplied;
            model.attachType = AttachmentTypeFreePhoto;
            model.originImgUrl = obj.originImg;
            model.smallImgUrl = obj.smallImg;
            model.blurImgUrl = obj.blurImg;
            [self.items addObject:model];

            LSMailCellHeightItem *heightItem = [[LSMailCellHeightItem alloc] init];
            heightItem.mailId = item.letterId;
            heightItem.attachType = AttachmentTypeFreePhoto;
            heightItem.url = obj.originImg;
            heightItem.height = CONTENTIMAGEHEIGHT;
            [self.heightItems addObject:heightItem];
        }
    }

    // 设置默认高度
    if (self.items.count > 0 && self.heightItems.count > 0) {
        if (self.items.count == self.heightItems.count) {
            for (LSMailCellHeightItem *item in self.heightItems) {
                self.tableViewHeight.constant += item.height;
            }
            self.tableViewTop.constant = TABLEVIEWTOP;
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Action
- (void)backToAction:(id)sender {
    if (self.quickReplyStr.length > 0 && [self.replyTextView.text isEqualToString:self.quickReplyStr]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if ([[LSSendMailDraftManager manager] isShowDraftDialogLadyId:self.letterItem.anchorId name:self.letterItem.anchorNickName content:self.replyTextView.text]) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromSelf(@"Back_Tip") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *saveAC = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Save Draft") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self alertView:AlertViewTypeBack clickCancleOrOther:0];
        }];
        UIAlertAction *deleAC = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Delete Draft") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self alertView:AlertViewTypeBack clickCancleOrOther:1];
        }];
        UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:saveAC];
        [alertVC addAction:deleAC];
        [alertVC addAction:cancelAC];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)replyAction:(id)sender {

    [[LiveModule module].analyticsManager reportActionEvent:GreetingMailClickReply eventCategory:EventCategoryGreetings];

    [self hiddenKeyBroad];
    // 跳转至完整回复页
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.sendDelegate = self;
    vc.loiId = self.letterItem.letterId;
    vc.anchorId = self.letterItem.anchorId;
    vc.anchorName = self.letterItem.anchorNickName;
    vc.photoUrl = self.letterItem.anchorAvatar;
    vc.quickReplyStr = self.replyTextView.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)fullScreenAction:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:GreetingMailClickFullScreen eventCategory:EventCategoryGreetings];

    [self hiddenKeyBroad];
    // 跳转至完整回复页
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.sendDelegate = self;
    vc.loiId = self.letterItem.letterId;
    vc.anchorId = self.letterItem.anchorId;
    vc.anchorName = self.letterItem.anchorNickName;
    vc.photoUrl = self.letterItem.anchorAvatar;
    vc.quickReplyStr = self.replyTextView.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)replySendAction:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:GreetingMailClickQuickReply eventCategory:EventCategoryGreetings];
    [self hiddenKeyBroad];

    if ([self.replyTextView.text isEqualToString:NSLocalizedStringFromSelf(@"DEAR")] || self.replyTextView.text.length == 0 || [self isEmpty:self.replyTextView.text]) {
        [self showAlertViewMsg:NSLocalizedStringFromSelf(@"NO_MAIL_TEXT") cancelBtnMsg:nil otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeDefault];
        return;
    }
    // 先请求发信费用 再回件
    [self showAlertViewMsg:NSLocalizedStringFromSelf(@"SEND_MAIL_TIP") cancelBtnMsg:NSLocalizedString(@"Cancel", nil) otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeSendTip];
}

- (void)addCreditsBtnDid:(id)sender {
    // 跳转充值界面 保存草稿箱
    [[LSSendMailDraftManager manager] saveMailDraftFromLady:self.letterItem.anchorId content:self.replyTextView.text];
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)headImageAction:(id)sender {
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = self.letterItem.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)hiddenKeyBroad {
    if (self.isShowKeyBorad) {
        [self closeAllInputView];
    }
}

#pragma mark - LSMailAttachmentViewControllerDelegate
- (void)emfAttachmentViewControllerDidBuyAttachments:(LSMailAttachmentViewController *)attachmentVC {
    // 回复意向信 刷新界面
    if (self.letterItem.letterId.length > 0) {
        [self getLoiDetail:self.letterItem.letterId];
    }
}

#pragma mark - LSSendMailViewControllerDelegate
- (void)sendMailIsSuccess:(LSSendMailViewController *)vc {
    // 更新状态已回复
    self.letterItem.hasReplied = YES;
    if ([self.greetingDetailDelegate respondsToSelector:@selector(lsGreetingDetailViewController:haveReplyGreetingDetailMail:index:)]) {
        [self.greetingDetailDelegate lsGreetingDetailViewController:self haveReplyGreetingDetailMail:self.letterItem index:self.greetingMailIndex];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (![self.replyTextView isEqual:scrollView]) {
        [self hiddenKeyBroad];
    }
}

#pragma mark - LSGreetingsDetailTableViewCellDelegate
- (void)greetingsDetailCellLoadImageSuccess:(CGFloat)height model:(LSMailAttachmentModel *)model {
    CGFloat tableHeight = 0;
    @synchronized(self.heightItems) {
        for (LSMailCellHeightItem *item in self.heightItems) {
            if (item.attachType == model.attachType && item.attachType == AttachmentTypeFreePhoto) {
                if ([item.url isEqualToString:model.originImgUrl]) {
                    item.height = height;
                }
            } else if (item.attachType == model.attachType && item.attachType == AttachmentTypeGreetingVideo) {
                if ([item.url isEqualToString:model.videoCoverUrl]) {
                    item.height = height;
                }
            }
            tableHeight += item.height;
        }
    }
    if (self.tableViewHeight.constant != tableHeight) {
        self.tableViewHeight.constant = tableHeight;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    LSMailAttachmentModel *model = self.items[indexPath.row];
    @synchronized(self.heightItems) {
        for (LSMailCellHeightItem *item in self.heightItems) {
            if (item.attachType == model.attachType && item.attachType == AttachmentTypeFreePhoto) {
                if ([item.url isEqualToString:model.originImgUrl]) {
                    cellHeight = item.height;
                }
            } else if (item.attachType == model.attachType && item.attachType == AttachmentTypeGreetingVideo) {
                if ([item.url isEqualToString:model.videoCoverUrl]) {
                    cellHeight = item.height;
                }
            }
        }
    }
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableCell = nil;
    LSMailAttachmentModel *model = self.items[indexPath.row];

    LSGreetingsDetailTableViewCell *cell = [LSGreetingsDetailTableViewCell getUITableViewCell:tableView];
    cell.delegate = self;
    [cell setupGreetingContent:model tableView:tableView];
    tableCell = cell;

    return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hiddenKeyBroad];

    LSMailAttachmentModel *model = self.items[indexPath.row];
    if (model.attachType == AttachmentTypeFreePhoto) {
        [[LiveModule module].analyticsManager reportActionEvent:GreetingMailClickPhoto eventCategory:EventCategoryGreetings];
    } else if (model.attachType == AttachmentTypeGreetingVideo) {
        [[LiveModule module].analyticsManager reportActionEvent:GreetingMailClickVideo eventCategory:EventCategoryGreetings];
    }

    LSMailAttachmentViewController *vc = [[LSMailAttachmentViewController alloc] initWithNibName:nil bundle:nil];
    vc.letterItem = self.letterItem;
    vc.attachmentsArray = self.items;
    vc.attachmentDelegate = self;
    vc.photoIndex = indexPath.row;
    LSNavigationController * nvc = [[LSNavigationController alloc] initWithRootViewController:vc];
    [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
    [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
    [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
    [self presentViewController:nvc
                       animated:NO
                     completion:nil];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (![self.replyTextView.text isEqualToString:self.quickReplyStr]) {
        [LSSendMailDraftManager manager].isEdit = YES;
    }

    if (self.replyTextView.text.length == 0) {
        self.replySendBtn.userInteractionEnabled = NO;
        self.replySendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x8CAFF7);
    } else {
        self.replySendBtn.userInteractionEnabled = YES;
        self.replySendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x97AF3);

        // 超过字符限制
        NSString *toBeString = textView.text;
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > MAXInputCount) {
                textView.text = [textView.text substringToIndex:MAXInputCount];
            }
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // 增加手势
    [self addSingleTap];
    return YES;
}

#pragma mark - WKWebViewDelegate
// 加载完webview (当main frame导航完成时，会回调)
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"LSGreetingDetailViewController::didFinishNavigation()");
    WeakObject(self, weakSelf);
    [webView evaluateJavaScript:@"document.body.offsetHeight;"
              completionHandler:^(id _Nullable height, NSError *_Nullable error) {
                  NSString *heightStr = [NSString stringWithFormat:@"%@", height];
                  weakSelf.contentViewHeight.constant = heightStr.floatValue;
              }];
}

#pragma mark -KeyboardNSNotification
- (void)keyboardDidShow:(NSNotification *)notification {
    self.isShowKeyBorad = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    self.isShowKeyBorad = NO;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // 动画收起键盘
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    // 获取第一次滑到最底的offsetY 防止scrollView.contentSize改变offsetY值获取不对
    if (!self.scrollViewOffy) {
        self.scrollViewOffy = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    }
    CGFloat offHeight = 0;
    if (height != 0) {
        if (IS_IPHONE_X) {
            self.replyViewBottom.constant = height - 35;
        } else {
            self.replyViewBottom.constant = height;
        }
        offHeight = self.scrollViewOffy + height;
    } else {
        self.replyViewBottom.constant = 0;
        offHeight = self.scrollView.contentSize.height - self.scrollView.bounds.size.height + height;
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
@end
