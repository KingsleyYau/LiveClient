//
//  LSMailDetailViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/12/17.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMailDetailViewController.h"
#import "LSMailAttachmentViewController.h"
#import "LSSendMailViewController.h"
#import "LSAddCreditsViewController.h"
#import "AnchorPersonalViewController.h"

#import "LSSessionRequestManager.h"
#import "LSGetEmfDetailRequest.h"
#import "LSGetSendMailPriceRequest.h"
#import "LSSendEmfRequest.h"

#import "LSChatTextView.h"
#import "IntroduceView.h"
#import <YYText.h>
#import "LSOutOfCreditsView.h"
#import "LSOutOfPoststampView.h"
#import "DialogTip.h"
#import "LSMailDetailFreePhotoCell.h"
#import "LSMailDetailPrivatePhotoCell.h"
#import "LSMailPrivateVideoCell.h"

#import "LiveRoomCreditRebateManager.h"
#import "LSChatTextAttachment.h"
#import "LSMailAttachmentModel.h"
#import "LSImageViewLoader.h"
#import "LSDateTool.h"
#import "LSSendMailDraftManager.h"
#import "LiveModule.h"
#import "LSShadowView.h"
#import "GetLeftCreditRequest.h"
#import "LSAnchorLetterPrivRequest.h"

#define TAP_HERE_URL @"TAP_HERE_URL"
#define MAXInputCount 6000
#define ReplyViewHeight 325
#define ATTACHMRNTSTIPTOP -26;

#define NavNormalHeight 64
#define NavIphoneXHeight 88

#define FREEPHOTO @"FREEPHOTO"
#define PRIVATEPHOTO @"PRIVATEPHOTO"
#define PRIVATEVIDEO @"PRIVATEVIDEO"

typedef enum : NSUInteger {
    AlertViewTypeDefault = 0,      //默认无操作
    AlertViewTypeBack,             //返回草稿
    AlertViewTypeSendTip,          //发送二次确认提示
    AlertViewTypeSendSuccessfully, //发送成功
    AlertViewTypeNoSendPermissions //没有发信权限
} AlertViewType;

@interface LSMailDetailViewController () <WKNavigationDelegate, WKUIDelegate, LSMailAttachmentViewControllerDelegate, UITextViewDelegate, UIScrollViewDelegate, LSChatTextViewDelegate, LSOutOfPoststampViewDelegate, LSOutOfCreditsViewDelegate, UITableViewDelegate, UITableViewDataSource, LSMailDetailFreePhotoCellDelegate, LSMailDetailPrivatePhotoCellDelegate, LSMailPrivateVideoCellDelegate, LSSendMailViewControllerDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *onlineImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet IntroduceView *wkWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;

@property (weak, nonatomic) IBOutlet UILabel *sendTimeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentsTipTop;

@property (weak, nonatomic) IBOutlet UILabel *attachmentsTip;

@property (weak, nonatomic) IBOutlet LSTableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;

// 回复view
@property (weak, nonatomic) IBOutlet LSChatTextView *replyTextView;
// textview阴影
@property (weak, nonatomic) IBOutlet UIView *textShadowView;
// 文本提示
@property (weak, nonatomic) IBOutlet YYLabel *infoTipLabel;
// 回复按钮
@property (weak, nonatomic) IBOutlet UIButton *replySendBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyViewHeight;

@property (weak, nonatomic) IBOutlet UIView *noCreditsView;
@property (weak, nonatomic) IBOutlet UIButton *addCreditsBtn;

@property (weak, nonatomic) IBOutlet UIView *nodataView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistance;

@property (nonatomic, strong) UILabel *navTitleLabel;
@property (nonatomic, strong) UIButton *navLeftBtn;
@property (nonatomic, strong) UIButton *navRightBtn;

// 数据源
@property (strong, nonatomic) NSMutableArray<LSMailAttachmentModel *> *items;
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
@property (nonatomic, assign) NSInteger stamps;
//买点弹窗
@property (nonatomic, strong) LSOutOfCreditsView *creditsView;
//邮票弹窗
@property (nonatomic, strong) LSOutOfPoststampView *poststampView;

@property (nonatomic, assign) CGFloat freeCellHeight;
@property (nonatomic, assign) CGFloat privateCellHeight;

@property (nonatomic, assign) CGFloat scrollViewOffy;

@property (nonatomic, strong) NSMutableArray *typeArray;
@property (nonatomic, strong) NSMutableArray<LSMailAttachmentModel *> *freeImages;
@property (nonatomic, strong) NSMutableArray<LSMailAttachmentModel *> *privateImages;
@property (nonatomic, strong) NSMutableArray<LSMailAttachmentModel *> *videos;

@end

@implementation LSMailDetailViewController

- (void)dealloc {
    NSLog(@"LSMailDetailViewController::dealloc()");

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initCustomParam {
    [super initCustomParam];

    self.isShowNavBar = NO;
    self.isHideNavBackButton = NO;
    
    self.isShowKeyBorad = NO;
    self.isSpendStamp = NO;

    self.freeCellHeight = 0;
    self.privateCellHeight = 0;
    self.scrollViewOffy = 0;

    self.items = [[NSMutableArray alloc] init];

    self.typeArray = [[NSMutableArray alloc] init];
    self.freeImages = [[NSMutableArray alloc] init];
    self.privateImages = [[NSMutableArray alloc] init];
    self.videos = [[NSMutableArray alloc] init];

    self.sessionManager = [[LSSessionRequestManager alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;

    self.scrollView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    // 默认隐藏内容列表
    self.attachmentsTip.text = @"";
    self.attachmentsTipTop = 0;
    self.tableViewHeight.constant = 0;
    self.tableView.scrollEnabled = NO;
    self.tableView.bounces = NO;

    self.replyBtn.hidden = YES;

    self.navTitleLabel = [[UILabel alloc] init];
    self.navTitleLabel.text = NSLocalizedStringFromSelf(@"TITLE");
    ;
    self.navTitleLabel.frame = CGRectMake(0, 0, 100, 44);
    self.navTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.navTitleLabel.font = [UIFont systemFontOfSize:19];

    self.navLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navLeftBtn addTarget:self action:@selector(backToAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navLeftBtn setImage:[UIImage imageNamed:@"LS_Nav_Back_b"] forState:UIControlStateNormal];
    self.navLeftBtn.frame = CGRectMake(0, 0, 30, 44);

    self.navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navRightBtn addTarget:self action:@selector(replyAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navRightBtn setImage:[UIImage imageNamed:@"Mail_Detail_Reply"] forState:UIControlStateNormal];
    self.navRightBtn.frame = CGRectMake(0, 0, 44, 44);

    [self setupTapLabelStyle];
    [self setupCornerRadius];
    [self setupTextView];

    self.wkWebView.scrollView.scrollEnabled = NO;

    // 头像
    [[LSImageViewLoader loader] loadImageFromCache:self.headImageView
                                           options:SDWebImageRefreshCached
                                          imageUrl:self.letterItem.anchorAvatar
                                  placeholderImage:LADYDEFAULTIMG
                                     finishHandler:^(UIImage *image){
                                     }];
    // 姓名
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"FROM_ANCHOR"), self.letterItem.anchorNickName];
    // 发信时间信件ID
    LSDateTool *tool = [[LSDateTool alloc] init];
    NSString *time = [tool showGreetingDetailTimeOfDate:[NSDate dateWithTimeIntervalSince1970:self.letterItem.letterSendTime]];
    self.sendTimeLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"MAIL_ID"), time, self.letterItem.letterId];

    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (@available(iOS 11, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    // 初始化草稿管理器
    [[LSSendMailDraftManager manager] initMailDraftLadyId:self.letterItem.anchorId name:self.letterItem.anchorNickName];
    self.quickReplyStr = [[LSSendMailDraftManager manager] getDraftContent:self.letterItem.anchorId];
    self.replyTextView.text = self.quickReplyStr;
    
    [self setupAlphaStatus:self.scrollView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.titleView = self.navTitleLabel;

    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navLeftBtn];
    self.navigationItem.leftBarButtonItem = leftButtonItem;

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navRightBtn];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.navigationController.navigationBar.hidden = NO;
    [self setupAlphaStatus:self.scrollView];
    
    // 判断是否读信受阻
    [self getLeftCredit];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupCornerRadius {
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.borderWidth = 1;
    self.headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headImageView.layer.masksToBounds = YES;

    self.onlineImageView.layer.cornerRadius = self.onlineImageView.frame.size.height / 2;
    self.onlineImageView.layer.borderWidth = 1;
    self.onlineImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.onlineImageView.layer.masksToBounds = YES;

    self.replyBtn.layer.cornerRadius = self.replyBtn.frame.size.height / 2;
    self.replyBtn.layer.masksToBounds = YES;
    self.replyBtn.layer.shadowColor = Color(0, 0, 0, 0.5).CGColor;
    self.replyBtn.layer.shadowOffset = CGSizeMake(0, 0);
    self.replyBtn.layer.shadowOpacity = 0.5;
    self.replyBtn.layer.shadowRadius = 1.0f;

    self.replyTextView.layer.cornerRadius = 5;
    self.replyTextView.layer.masksToBounds = YES;

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

    self.replyTextView.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DEAR"), self.letterItem.anchorNickName];
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
    [self.poststampView removeFromSuperview];
    self.poststampView = nil;
    self.isSpendStamp = NO;
    [self setupInfoTipLabel];
    [self sendMail];
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
    [self.creditsView removeFromSuperview];
    self.creditsView = nil;
    [self addCreditsBtnDid:nil];
}

- (void)lsOutOfCreditsView:(LSOutOfCreditsView *)addView didSelectSendPoststamp:(UIButton *)SendPoststampBtn {
    [self.creditsView removeFromSuperview];
    self.creditsView = nil;
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

#pragma mark - HTTP请求
- (void)getLeftCredit {
    [self showLoading];
    WeakObject(self, weakSelf);
    [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                // 判断是否读信受阻
                if (postStamp < 1 && credit < 0.8 && !weakSelf.letterItem.hasRead) {
                    weakSelf.addCreditsBtn.layer.cornerRadius = 5;
                    weakSelf.noCreditsView.hidden = NO;
                    weakSelf.nodataView.hidden = YES;
                    [weakSelf hideLoading];
                } else {
                    weakSelf.noCreditsView.hidden = YES;

                    // 如果用户可以发信 则获取主播信件权限 反之请求信件详情
                    if ([LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailPriv) {
                        if (weakSelf.letterItem.anchorId.length > 0) {
                            [weakSelf getAnchorLetterPriv:weakSelf.letterItem.anchorId];
                        }
                    } else {
                        if (weakSelf.letterItem.letterId.length > 0) {
                            [weakSelf getMailDeatail:weakSelf.letterItem.letterId];
                        }
                    }
                }
            } else {
                [weakSelf hideLoading];
                [[DialogTip dialogTip] showDialogTip:weakSelf.view tipText:errmsg];
            }
        });

    }];
}

- (void)getAnchorLetterPriv:(NSString *)anchorId {
    WeakObject(self, weakSelf);
    LSAnchorLetterPrivRequest *request = [[LSAnchorLetterPrivRequest alloc] init];
    request.anchorId = anchorId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSAnchorLetterPrivItemObject *item) {
        NSLog(@"LSMailDetailViewController::LSAnchorLetterPrivRequest ([获取主播信件权限 success : %@, errnum : %d, errmsg : %@, userCanSend : %d, anchorCanSend : %d])", BOOL2SUCCESS(success), errnum, errmsg, item.userCanSend, item.anchorCanSend);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                if (!item.anchorCanSend) {
                    weakSelf.replyViewHeight.constant = 0;
                    [weakSelf.view layoutSubviews];
                }
                // 获取权限成功 请求信件详情
                if (weakSelf.letterItem.letterId.length > 0) {
                    [weakSelf getMailDeatail:weakSelf.letterItem.letterId];
                }
            } else {
                [weakSelf hideLoading];
                [[DialogTip dialogTip] showDialogTip:weakSelf.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getSendMailPrice {
    [self showLoading];
    WeakObject(self, weakSelf);
    LSGetSendMailPriceRequest *request = [[LSGetSendMailPriceRequest alloc] init];
    request.imgNumber = 0;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, double creditPrice, double stampPrice) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSMailDetailViewController::LSGetSendMailPriceRequest (获取发送信件所需余额 %@ errmsg: %@ errnum: %d creditPrice: %f stampPrice : %f)", BOOL2SUCCESS(success), errmsg, errnum, creditPrice, stampPrice);
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
    request.emfId = self.letterItem.letterId;
    request.content = self.replyTextView.text;
    if (self.isSpendStamp) {
        request.comsumeType = LSLETTERCOMSUMETYPE_STAMP;
    } else {
        request.comsumeType = LSLETTERCOMSUMETYPE_CREDIT;
    }
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *emfId) {
        NSLog(@"LSMailDetailViewController::sendMail (发送信件 %@ errmsg: %@ errnum: %d)", BOOL2SUCCESS(success), errmsg, errnum);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideLoading];
            if (success) {
                // 标记为已回复
                weakSelf.letterItem.hasReplied = YES;
                if ([weakSelf.mailDetailDelegate respondsToSelector:@selector(lsMailDetailViewController:haveReplyMailDetailMail:index:)]) {
                    [weakSelf.mailDetailDelegate lsMailDetailViewController:weakSelf haveReplyMailDetailMail:weakSelf.letterItem index:weakSelf.mailIndex];
                }

                [weakSelf showAlertViewMsg:NSLocalizedStringFromSelf(@"SEND_MAIL_SUCCESSFULLY") cancelBtnMsg:NSLocalizedString(@"OK", nil) otherBtnMsg:nil alertViewType:AlertViewTypeSendSuccessfully];
                [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg){

                }];
                [[LSSendMailDraftManager manager] deleteMailDraft:weakSelf.letterItem.anchorId];
                [[LSSendMailDraftManager manager] initMailDraftLadyId:weakSelf.letterItem.anchorId name:weakSelf.letterItem.anchorNickName];
                weakSelf.quickReplyStr = [[LSSendMailDraftManager manager] getDraftContent:weakSelf.letterItem.anchorId];
                weakSelf.replyTextView.text = weakSelf.quickReplyStr;
                
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

- (void)getMailDeatail:(NSString *)mailId {
    [self showAndResetLoading];
    WeakObject(self, weakSelf);
    LSGetEmfDetailRequest *request = [[LSGetEmfDetailRequest alloc] init];
    request.emfId = mailId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSHttpLetterDetailItemObject *item) {
        NSLog(@"LSMailDetailViewController::getMailDeatail (请求信件详情 success : %@, errnum : %d, errmsg : %@, letterId : %@)", BOOL2SUCCESS(success), errnum, errmsg, item.letterId);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideAndResetLoading];
            if (success) {
                [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg){

                }];

                // 设置已读
                weakSelf.letterItem.hasRead = YES;
                [weakSelf setupMailDetail:item];
                // 刷新列表已读信息
                if ([weakSelf.mailDetailDelegate
                        respondsToSelector:@selector(lsMailDetailViewController:haveReadMailDetailMail:index:)]) {
                    [weakSelf.mailDetailDelegate lsMailDetailViewController:weakSelf haveReadMailDetailMail:weakSelf.letterItem index:weakSelf.mailIndex];
                }
            } else {
                [[DialogTip dialogTip] showDialogTip:weakSelf.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)setupMailDetail:(LSHttpLetterDetailItemObject *)item {
    self.replyBtn.hidden = NO;
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

    // 显示邮件内容
    [self setupTableView:item];
}

- (void)setupTableView:(LSHttpLetterDetailItemObject *)item {
    [self.items removeAllObjects];
    [self.typeArray removeAllObjects];
    [self.freeImages removeAllObjects];
    [self.privateImages removeAllObjects];
    [self.videos removeAllObjects];

    CGFloat imageWidth = (self.tableView.frame.size.width - 40) / 3;

    if (item.letterImgList.count > 0) {
        for (LSHttpLetterImgItemObject *obj in item.letterImgList) {
            LSMailAttachmentModel *model = [[LSMailAttachmentModel alloc] init];
            if (!obj.isFee) {
                model.attachType = AttachmentTypeFreePhoto;
                model.mailId = item.letterId;
                model.originImgUrl = obj.originImg;
                model.smallImgUrl = obj.smallImg;
                model.blurImgUrl = obj.blurImg;
                [self.items insertObject:model atIndex:0];
                [self.freeImages addObject:model];

            } else {
                model.attachType = AttachmentTypePrivatePhoto;
                model.mailId = item.letterId;
                model.originImgUrl = obj.originImg;
                model.smallImgUrl = obj.smallImg;
                model.blurImgUrl = obj.blurImg;
                model.photoId = obj.resourceId;
                model.photoDesc = obj.describe;
                model.expenseType = (int)obj.status;
                [self.items addObject:model];
                [self.privateImages addObject:model];
            }
        }
    }

    if (item.letterVideoList.count > 0) {
        for (LSHttpLetterVideoItemObject *obj in item.letterVideoList) {
            LSMailAttachmentModel *model = [[LSMailAttachmentModel alloc] init];
            model.mailId = item.letterId;
            model.attachType = AttachmentTypePrivateVideo;
            model.videoUrl = obj.video;
            model.videoTime = obj.videoTotalTime;
            model.videoCoverUrl = obj.coverOriginImg;
            model.videoId = obj.resourceId;
            model.videoSmallCoverUrl = obj.coverSmallImg;
            model.videoDesc = obj.describe;
            model.expenseType = (int)obj.status;
            [self.items addObject:model];
            [self.videos addObject:model];
        }
    }

    CGFloat tableHeight = 0;
    if (self.freeImages.count > 0) {
        self.freeCellHeight = 146;
        tableHeight += self.freeCellHeight;
        [self.typeArray addObject:FREEPHOTO];
    }
    if (self.privateImages.count > 0) {
        self.privateCellHeight = (imageWidth + 35) * (self.privateImages.count > 3 ? 2 : 1) + 67;
        tableHeight += self.privateCellHeight;
        [self.typeArray addObject:PRIVATEPHOTO];
    }
    if (self.videos.count > 0) {
        tableHeight += [LSMailPrivateVideoCell cellHeight];
        [self.typeArray addObject:PRIVATEVIDEO];
    }

    if (self.typeArray.count > 0) {
        self.attachmentsTip.text = NSLocalizedStringFromSelf(@"0PN-Cz-SU5.text");
        self.attachmentsTipTop.constant = ATTACHMRNTSTIPTOP;
        self.tableViewHeight.constant = tableHeight;
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
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
    [[LiveModule module].analyticsManager reportActionEvent:MailClickReply eventCategory:EventCategoryMail];
    [self hiddenKeyBroad];
    // 跳转至完整回复页
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.sendDelegate = self;
    vc.emfId = self.letterItem.letterId;
    vc.anchorId = self.letterItem.anchorId;
    vc.anchorName = self.letterItem.anchorNickName;
    vc.photoUrl = self.letterItem.anchorAvatar;
    vc.quickReplyStr = self.replyTextView.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)fullScreenAction:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:MailClickFullScreen eventCategory:EventCategoryMail];
    [self hiddenKeyBroad];
    // 跳转至完整回复页
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.sendDelegate = self;
    vc.emfId = self.letterItem.letterId;
    vc.anchorId = self.letterItem.anchorId;
    vc.anchorName = self.letterItem.anchorNickName;
    vc.photoUrl = self.letterItem.anchorAvatar;
    vc.quickReplyStr = self.replyTextView.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)replySendAction:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:MailClickQuickReply eventCategory:EventCategoryMail];
    [self hiddenKeyBroad];

    if ([self.replyTextView.text isEqualToString:[NSString stringWithFormat:NSLocalizedStringFromSelf(@"DEAR"), self.letterItem.anchorNickName]] || self.replyTextView.text.length == 0 || [self isEmpty:self.replyTextView.text]) {
        [self showAlertViewMsg:NSLocalizedStringFromSelf(@"NO_MAIL_TEXT") cancelBtnMsg:nil otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeDefault];
        return;
    }
    // 先请求发信费用 再回件
    [self showAlertViewMsg:NSLocalizedStringFromSelf(@"SEND_MAIL_TIP") cancelBtnMsg:NSLocalizedString(@"Cancel", nil) otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeSendTip];
}

- (IBAction)addCreditsBtnDid:(id)sender {
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

- (void)hiddenKeyBroad {
    if (self.isShowKeyBorad) {
        [self closeAllInputView];
    }
}

#pragma mark - LSMailAttachmentViewControllerDelegate
- (void)emfAttachmentViewControllerDidBuyAttachments:(LSMailAttachmentViewController *)attachmentVC {
    // 回复意向信 刷新界面
    if (self.letterItem.letterId.length > 0) {
        [self getMailDeatail:self.letterItem.letterId];
    }
}

#pragma mark - LSSendMailViewControllerDelegate
- (void)sendMailIsSuccess:(LSSendMailViewController *)vc {
    // 标记为已回复
    self.letterItem.hasReplied = YES;
    if ([self.mailDetailDelegate respondsToSelector:@selector(lsMailDetailViewController:haveReplyMailDetailMail:index:)]) {
        [self.mailDetailDelegate lsMailDetailViewController:self haveReplyMailDetailMail:self.letterItem index:self.mailIndex];
    }
}

#pragma mark - LSMailDetailFreePhotoCellDelegate/LSMailDetailPrivatePhotoCellDelegate/LSMailPrivateVideoCellDelegate
- (void)freePhotoDidClick:(LSMailAttachmentModel *)model {
    [[LiveModule module].analyticsManager reportActionEvent:MailClickPhoto eventCategory:EventCategoryMail];
    for (int index = 0; index < self.items.count; index++) {
        LSMailAttachmentModel *item = self.items[index];
        if (model.attachType == item.attachType && model.attachType == AttachmentTypeFreePhoto) {
            if ([model.originImgUrl isEqualToString:item.originImgUrl]) {
                LSMailAttachmentViewController *vc = [[LSMailAttachmentViewController alloc] initWithNibName:nil bundle:nil];
                vc.letterItem = self.letterItem;
                vc.attachmentsArray = self.items;
                vc.attachmentDelegate = self;
                vc.photoIndex = index;
                LSNavigationController * nvc = [[LSNavigationController alloc] initWithRootViewController:vc];
                [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
                [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
                [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
                [self presentViewController:nvc
                                   animated:NO
                                 completion:nil];
                return;
            }
        }
    }
}

- (void)didCollectionViewItem:(NSInteger)row model:(LSMailAttachmentModel *)model {
    [[LiveModule module].analyticsManager reportActionEvent:MailClickPaidPhoto eventCategory:EventCategoryMail];
    for (int index = 0; index < self.items.count; index++) {
        LSMailAttachmentModel *item = self.items[index];
        if (model.attachType == item.attachType && model.attachType == AttachmentTypePrivatePhoto) {
            if ([model.photoId isEqualToString:item.photoId]) {
                LSMailAttachmentViewController *vc = [[LSMailAttachmentViewController alloc] initWithNibName:nil bundle:nil];
                vc.letterItem = self.letterItem;
                vc.attachmentsArray = self.items;
                vc.attachmentDelegate = self;
                vc.photoIndex = index;
                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
                [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
                [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
                [self presentViewController:nvc
                                   animated:NO
                                 completion:nil];
                return;
            }
        }
    }
}

- (void)privateVideoDidClick:(LSMailAttachmentModel *)model {
    [[LiveModule module].analyticsManager reportActionEvent:MailClickPaidVideo eventCategory:EventCategoryMail];
    for (int index = 0; index < self.items.count; index++) {
        LSMailAttachmentModel *item = self.items[index];
        if (model.attachType == item.attachType && model.attachType == AttachmentTypePrivateVideo) {
            if ([model.videoId isEqualToString:item.videoId]) {
                LSMailAttachmentViewController *vc = [[LSMailAttachmentViewController alloc] initWithNibName:nil bundle:nil];
                vc.letterItem = self.letterItem;
                vc.attachmentsArray = self.items;
                vc.attachmentDelegate = self;
                vc.photoIndex = index;
                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
                [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
                [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
                [self presentViewController:nvc
                                   animated:NO
                                 completion:nil];
                return;
            }
        }
    }
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    NSString *type = self.typeArray[indexPath.row];
    if ([type isEqualToString:FREEPHOTO]) {
        cellHeight = self.freeCellHeight;
    } else if ([type isEqualToString:PRIVATEPHOTO]) {
        cellHeight = self.privateCellHeight;
    } else if ([type isEqualToString:PRIVATEVIDEO]) {
        cellHeight = [LSMailPrivateVideoCell cellHeight];
    }
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.typeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableCell = nil;
    NSString *type = self.typeArray[indexPath.row];
    if ([type isEqualToString:FREEPHOTO]) {
        LSMailAttachmentModel *model = self.freeImages.firstObject;
        LSMailDetailFreePhotoCell *cell = [LSMailDetailFreePhotoCell getUITableViewCell:tableView];
        cell.delegate = self;
        [cell setupImageDetail:model];
        tableCell = cell;
    } else if ([type isEqualToString:PRIVATEPHOTO]) {
        LSMailDetailPrivatePhotoCell *cell = [LSMailDetailPrivatePhotoCell getUITableViewCell:tableView];
        cell.delegate = self;
        [cell setupCollection:self.privateImages];
        tableCell = cell;
    } else if ([type isEqualToString:PRIVATEVIDEO]) {
        LSMailAttachmentModel *model = self.videos.firstObject;
        LSMailPrivateVideoCell *cell = [LSMailPrivateVideoCell getUITableViewCell:tableView];
        cell.delegate = self;
        [cell setupVideoDetail:model];
        tableCell = cell;
    }
    return tableCell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (![self.replyTextView isEqual:scrollView]) {
        [self hiddenKeyBroad];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![self.replyTextView isEqual:scrollView]) {
        [self setupAlphaStatus:scrollView];
    }
    [self.wkWebView setNeedsLayout];
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
        // 获取是否存在高亮部分
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
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
    NSLog(@"LSMailDetailViewController::didFinishNavigation()");
      __block CGFloat webViewHeight;
    [self.wkWebView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result,NSError * _Nullable error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     webViewHeight = [result doubleValue];
                    self.contentViewHeight.constant = webViewHeight;
                    self.wkWebView.frame = CGRectMake(0, 0, SCREEN_WIDTH, webViewHeight);
                     
                 });
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

// 设置透明状态
- (void)setupAlphaStatus:(UIScrollView *)scrollView {
    CGFloat navHeight = NavNormalHeight;

    if (IS_IPHONE_X) {
        navHeight = NavIphoneXHeight;
    }

    CGFloat per = scrollView.contentOffset.y / navHeight;
    if (scrollView.contentOffset.y >= navHeight) {
        [self setNeedsNavigationBackground:1];
    } else {
        [self setNeedsNavigationBackground:per];
    }
}

- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    // 导航栏背景透明度设置
    [super setNavigationBackgroundAlpha:alpha];
    self.navTitleLabel.alpha = alpha;
    self.navRightBtn.alpha = alpha;
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
