//
//  ChatViewController.m
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatViewController.h"
//#import "AddCreditsViewController.h"

#import "ChatTextLadyTableViewCell.h"
#import "ChatTextSelfTableViewCell.h"

#import "ChatEmotionKeyboardView.h"
#import "ChatEmotionChooseView.h"

//#import "Message.h"
//#import "LiveChatManager.h"

//#import "ContactManager.h"

//#import "PaymentManager.h"
//#import "PaymentErrorCode.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageViewLoader.h"

#import "ChatNomalSmallEmotionView.h"
//#import "LadyDetailMsgManager.h"
#define ADD_CREDIT_URL @"ADD_CREDIT_URL"
#define INPUTMESSAGEVIEW_MAX_HEIGHT 44.0 * 2

#define TextMessageFontSize 18
#define SystemMessageFontSize 16
#define WarningMessageFontSize 16
#define MessageGrayColor [UIColor colorWithIntRGB:180 green:180 blue:180 alpha:255]
#define halfWidth self.view.frame.size.width * 0.5f
#define PreloadPhotoCount 10
#define maxInputCount 200

#define column 5
#define imageRow 2
#define defaultPage 1

typedef enum AlertType {
    AlertType200Limited = 100000,
    AlertTypeCameraAllow,
    AlertTypeCameraDisable,
    AlertTypePhotoAllow,
    AlertTypeInChatAllow,
    AlertTypeInChatToCamShare
} AlertType;

typedef enum AlertPayType {
    AlertTypePayDefault = 200000,
    AlertTypePayAppStorePay,
    AlertTypePayCheckOrder,
    AlertTypePayMonthFee
} AlertPayType;

@interface ChatViewController ()  <UIAlertViewDelegate, ChatTextSelfDelegate, KKCheckButtonDelegate, ChatEmotionChooseViewDelegate, ChatTextViewDelegate, ImageViewLoaderDelegate,UINavigationControllerDelegate, ChatEmotionKeyboardViewDelegate,ChatNormalSmallEmotionViewDelegate,UIScrollViewDelegate> {
    CGRect _orgFrame;
}

/**
 *  表情选择器键盘
 */
@property (nonatomic, strong) ChatEmotionKeyboardView *chatEmotionKeyboardView;

/**
 *  表情列表
 */
@property (nonatomic, retain) NSArray *emotionArray;
/**
 *  表情列表(用于查找)
 */
@property (nonatomic, retain) NSDictionary *emotionDict;

/**
 *  消息列表
 */
@property (atomic, retain) NSMutableArray *msgArray;

/**
 *  自定义消息
 */
@property (nonatomic, retain) NSMutableDictionary *msgCustomDict;

/**
 *  Livechat管理器
 */
//@property (nonatomic, strong) LiveChatManager *liveChatManager;
/**
 *  单击收起输入控件手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

/**
 *  头像下载器
 */
@property (nonatomic, strong) ImageViewLoader *imageViewLoader;

/** 消息数据 */
//@property (nonatomic,strong) LiveChatMsgItemObject *msgItem;

/**
 *  支付管理器
 */
//@property (nonatomic, strong) PaymentManager* paymentManager;
/**
 *  当前支付订单号
 */
@property (nonatomic, strong) NSString* orderNo;

/** 键盘弹出高度 */
@property (nonatomic,assign) CGFloat keyboardHeight;

#pragma mark - 表情属性

/**
 表情缩略图缓存列表
 */
@property (strong, atomic) NSMutableDictionary* emotionImageCacheDict;
/**
 表情播放图片缓存列表
 */
@property (strong, atomic) NSMutableDictionary* emotionImageArrayCacheDict;
@property (nonatomic,strong) NSArray *nomalSmallEmotionArray;
/**
 小高表情缩略图缓存列表
 */
@property (strong, atomic) NSMutableDictionary* smallEmotionImageCacheDict;
@property (nonatomic,copy) NSAttributedString *emotionAttributedString;

/** 普通表情*/
@property (nonatomic,strong)  ChatEmotionChooseView *chatNomalEmotionView;

/** 高亲密度表情*/
@property (nonatomic,strong)  ChatEmotionChooseView *chatFriendlyChooseView;

/** 女士个人详情管理器 */
//@property (nonatomic,strong) LadyDetailMsgManager *detailMsgManager;

/** 消息 */
//@property (nonatomic,strong) Message *msg;

@end

@implementation ChatViewController

#pragma mark - Systems
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //    BOOL result = self.textView.userInteractionEnabled;
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if( !self.viewDidAppearEver ) {
        // 刷新消息列表
        [self reloadData:YES scrollToEnd:YES animated:NO];
        
//        // 检测用户聊天状态
//        LiveChatUserItemObject* user = [self.liveChatManager getUserWithId:self.womanId];
//        if( user.chatType != LCUserItem::ChatType::LC_CHATTYPE_IN_CHAT_CHARGE ) {
//            // 检测试聊券
//            [self.liveChatManager checkTryTicket:self.womanId];
//        }
//
    }

//    [self.liveChatManager getLadyCamStatus:self.womanId];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    [self.paymentManager removeDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 关闭输入框
    [self closeAllInputView];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    self.paymentManager = [PaymentManager manager];
//    [self.paymentManager addDelegate:self];
}


#pragma mark - 界面逻辑
- (void)initCustomParam {
    // 初始化父类参数
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"Chat", nil);
    
    self.womanId = @"";
    self.firstname = @"";
    self.photoURL = @"";
    
//    self.liveChatManager = [LiveChatManager manager];
//    [self.liveChatManager addDelegate:self];
//    
//    self.detailMsgManager = [LadyDetailMsgManager manager];
//    [self.detailMsgManager addDelegate:self];
    
    // 加载普通表情
    [self reloadEmotion];
    
    // 初始化表情缓存
    self.emotionImageCacheDict = [NSMutableDictionary dictionary];
    self.emotionImageArrayCacheDict = [NSMutableDictionary dictionary];
    self.smallEmotionImageCacheDict = [NSMutableDictionary dictionary];
    
    // 初始化自定义消息列表
    self.msgCustomDict = [NSMutableDictionary dictionary];
}

- (void)dealloc {
//    [self.liveChatManager removeDelegate:self];
//    [self.detailMsgManager removeDelegate:self];
    // 清空自定义消息
    [self clearCustomMessage];
    [self.imageViewLoader stop];
}

/**
 *  初始化导航栏
 */
- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 设置导航栏返回按钮
    [self setBackleftBarButtonItemOffset:15];
    
    // 标题
    ChatTitleView *titleView = [[ChatTitleView alloc] init];
    titleView.personName.text = self.firstname;
    titleView.personName.textColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = titleView;
    
    self.imageViewLoader = [[ImageViewLoader alloc] init];
    self.imageViewLoader.view = titleView.personIcon;

//    // 获取本批联系人用户信息
//    //    [self.liveChatManager getUserInfo:self.womanId];
//    [self.detailMsgManager getLadyUserInfo:self.womanId];
}

/**
 *  初始化界面
 */
- (void)setupContainView {
    [super setupContainView];
    
    [self setupTableView];
    [self setupInputView];
    [self setupEmotionInputView];
}

/**
 *  初始化消息列表
 */
- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
}

/**
 *  初始化输入框
 */
- (void)setupInputView {
    // 文字输入
    self.textView.placeholder = NSLocalizedStringFromSelf(@"Tips_Input_Message_Here");
    self.textView.chatTextViewDelegate = self;
    self.textView.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(14)];
    // 表情输入
    self.emotionBtn.adjustsImageWhenHighlighted = NO;
    self.emotionBtn.selectedChangeDelegate = self;
    [self.emotionBtn setImage:[UIImage imageNamed:@"Chat-EmotionGray"] forState:UIControlStateNormal];
    [self.emotionBtn setImage:[UIImage imageNamed:@"Chat-EmotionBlue"] forState:UIControlStateSelected];
    
    self.sendMsgBtn.layer.cornerRadius = 5;
    self.sendMsgBtn.layer.masksToBounds = YES;
    [self.sendMsgBtn addTarget:self action:@selector(sendMsgAction:) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  初始化表情选择器
 */
- (void)setupEmotionInputView {

    // 普通表情
    if (self.chatNomalEmotionView == nil) {
        self.chatNomalEmotionView = [ChatEmotionChooseView emotionChooseView:self];
        self.chatNomalEmotionView.delegate = self;
        self.chatNomalEmotionView.emotions = self.emotionArray;
        [self.chatNomalEmotionView reloadData];
    }
    
    // 高亲密度表情
    if (self.chatFriendlyChooseView == nil) {
        self.chatFriendlyChooseView = [ChatEmotionChooseView emotionChooseView:self];
        self.chatFriendlyChooseView.delegate = self;
        self.chatFriendlyChooseView.emotions = self.emotionArray;
        [self.chatFriendlyChooseView reloadData];
    }
    
    // 表情选择器
    if( self.chatEmotionKeyboardView == nil ) {
        self.chatEmotionKeyboardView = [ChatEmotionKeyboardView chatEmotionKeyboardView:self];
        self.chatEmotionKeyboardView.delegate = self;
        
        [self.view addSubview:self.chatEmotionKeyboardView];
        
        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.inputMessageView.mas_width);
            make.height.equalTo(@262);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(0);
        }];
        
        NSMutableArray* array = [NSMutableArray array];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image = [UIImage imageNamed:@"Chat-SmallEmotion"];
        [button setImage:image forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
        [array addObject:button];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        image = [UIImage imageNamed:@"Chat-LargeEmotion"];
        [button setImage:image forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
        [array addObject:button];
        
        self.chatEmotionKeyboardView.buttons = array;
    }
}

#pragma mark - 头像下载完成处理
- (void)loadImageFinish:(ImageViewLoader *)imageViewLoader success:(BOOL)success {
    
}

#pragma mark - 文本和表情输入控件管理
/**
 *  增加点击收起键盘手势
 */
- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllInputView)];
        [self.tableView addGestureRecognizer:self.singleTap];
    }
}

/**
 *  移除点击收起键盘手势
 */
- (void)removeSingleTap {
    if( self.singleTap ) {
        [self.tableView removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

/**
 *  显示系统键盘
 */
- (void)showKeyboardView {
    // 增加手势
    [self addSingleTap];
    
    self.textView.inputView = nil;
    [self.textView becomeFirstResponder];
}

/**
 *  显示表情选择
 */
- (void)showEmotionView {
    // 增加手势
    [self addSingleTap];
    
    // 关闭系统键盘
    [self.textView resignFirstResponder];
    
    if( self.inputMessageViewBottom.constant != -self.chatEmotionKeyboardView.frame.size.height ) {
        // 未显示则显示
        [self moveInputBarWithKeyboardHeight:self.chatEmotionKeyboardView.frame.size.height withDuration:0.25];
    }

    [self.chatEmotionKeyboardView reloadData];
}

/**
 *  关闭所有输入控件
 */
- (void)closeAllInputView {
    // 降低加速度
    self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    // 移除手势
    [self removeSingleTap];
    
    // 关闭表情输入
    if( self.emotionBtn.selected == YES ) {
        self.emotionBtn.selected = NO;
        [self moveInputBarWithKeyboardHeight:0 withDuration:0.25];
    }
    
    // 关闭系统键盘
    [self.textView resignFirstResponder];
    
}

#pragma mark - 点击按钮事件
/**
 *  点击发送
 *
 *  @param sender 按钮
 */
- (void)sendMsgAction:(id)sender {
    
    if( self.textView.text.length > 0 ) {
        [self sendMsg:self.textView.text];
    }
}

#pragma mark - 点击消息提示按钮
- (void)chatTextSelfRetryButtonClick:(ChatTextSelfTableViewCell *)cell {
        self.textView.userInteractionEnabled = NO;
    NSIndexPath * path = [self.tableView indexPathForCell:cell];
    [self handleErrorMsg:path.row];
}

#pragma mark - 点击弹窗提示
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self closeAllInputView];
    
    NSInteger index = alertView.tag;
    if( index < self.msgArray.count ) {
//        Message* msg = [self.msgArray objectAtIndex:index];
//        LiveChatMsgProcResultObject* procResult = msg.liveChatMsgItemObject.procResult;
        
//        if( procResult ) {
//            switch (procResult.errType) {
//                case LCC_ERR_FAIL:
////                {
//                    // php错误
////                    if( [procResult.errNum isEqualToString:LIVECHAT_NO_MONEY] ) {
////                        // 帐号余额不足, 弹出买点
////                        dispatch_async(dispatch_get_main_queue(), ^{
////                            [self addCreditsViewShow];
////                        });
////                    } else {
//                        // 点击重发
////                        if( buttonIndex != alertView.cancelButtonIndex ) {
////                            [self reSendMsg:index];
////                        }
////                    }
//                    
////                }break;
//                case LCC_ERR_NOTRANSORAGENTFOUND:// 没有找到翻译或机构
//                case LCC_ERR_BLOCKUSER:// 对方为黑名单用户（聊天）
//                case LCC_ERR_SIDEOFFLINE:
////                {
////                    // 对方不在线（聊天）
////
////                    // 重新获取当前女士用户状态
////                    LiveChatUserItemObject* user = [self.liveChatManager getUserWithId:self.womanId];
////                    
////                    if( user) {
////                        if (user.statusType == USTATUS_ONLINE) {
////                            // 用户重新在线, 重发
////                            if( buttonIndex != alertView.cancelButtonIndex ) {
////                                [self reSendMsg:index];
////                            }
////                        }
////                        else
////                        {
////                            // 用户不在线 发EMF
////                            if( buttonIndex != alertView.cancelButtonIndex ) {
////                                EMFViewController *emfVC = [[EMFViewController alloc] initWithNibName:nil bundle:nil];
////                                emfVC.womanid = self.womanId;
////                                [self.navigationController pushViewController:emfVC animated:YES];
////                                return;
////                            }
////                        }
////                    }
////                }break;
//                case LCC_ERR_NOMONEY:{
//                    // 帐号余额不足, 弹出买点
////                    [self addCreditsViewShow];
//                    // 重新获取当前女士用户状态
//                    LiveChatUserItemObject* user = [self.liveChatManager getUserWithId:self.womanId];
//                    if( user) {
//                        if (user.statusType == USTATUS_ONLINE) {
//                            // 用户重新在线, 重发
//                            if( buttonIndex != alertView.cancelButtonIndex ) {
//                                [self reSendMsg:index];
//                            }
//                        }
//                        else
//                        {
//                            // 用户不在线 发EMF
//                            if( buttonIndex != alertView.cancelButtonIndex ) {
//                                SendEMFViewController * emfVC = [[SendEMFViewController alloc]initWithNibName:nil bundle:nil];
//                                emfVC.womanid = self.womanId;
//                                emfVC.photoURL = self.photoURL;
//                                [self.navigationController pushViewController:emfVC animated:YES];
//                                return;
//                            }
//                        }
//                    }
//
////                    // 其他未处理错误, 重发
////                    if( buttonIndex != alertView.cancelButtonIndex ) {
////                        [self reSendMsg:index];
////                    }
//                    //                    [self performSelector:@selector(addCreditsViewShow) withObject:nil afterDelay:self.duration];
//                }break;
//                default:{
//                    // 其他未处理错误, 重发
//                    if( buttonIndex != alertView.cancelButtonIndex ) {
//                        [self reSendMsg:index];
//                    }
//                    
//                }break;
//            }
//        }
//    } else {
//        switch (index) {
//            case AlertType200Limited:{
//                // 200个字符限制
//            }break;
//            case AlertTypeCameraAllow:{
//                // 不允许相机提示
//            }break;
//            case AlertTypeCameraDisable:{
//                // 不能使用相册提示
//            }break;
//            case AlertTypePhotoAllow:{
//                // 不允许相册提示
//            }break;
//            case AlertTypeInChatAllow:{
//                // 开聊才能发图
//            }break;
//            case AlertTypeInChatToCamShare://是否CamShare
//            {
//                if( buttonIndex != alertView.cancelButtonIndex ) {
//                    [self camshareVC];
//                }
//            }
//                break;
//            case AlertTypePayDefault: {
//                // 点击普通提示
//            }break;
//            default:
//                break;
//        }
////            case AlertTypePayAppStorePay: {
////                // Apple支付中
////                switch (buttonIndex) {
////                    case 0:{
////                        // 点击取消
////                        [self cancelPay];
////                    }break;
////                    case 1:{
////                        // 点击重试
////                        [self showLoading];
////                        [self.paymentManager retry:self.orderNo];
////                        
////                    }break;
////                    default:
////                        break;
////                }
////            }break;
////            case AlertTypePayCheckOrder: {
////                // 账单验证中
////                switch (buttonIndex) {
////                    case 0:{
////                        // 点击取消, 自动验证
////                        [self.paymentManager autoRetry:self.orderNo];
////                        [self cancelPay];
////                    }break;
////                    case 1:{
////                        // 点击重试, 手动验证
////                        [self showLoading];
////                        [self.paymentManager retry:self.orderNo];
////                    }break;
////                    default:
////                        break;
////                }
////            }
////            case AlertTypePayMonthFee:{
////                switch (buttonIndex) {
////                    case 0:{
////                    }break;
////                    case 1:{
////                        [self showLoading];
////                        [self.paymentManager pay:@"SP2010"];
////                    }break;
////                        
////                    default:
////                        break;
////                }
////                
////            }
////                
////        }
//        
    }
}


#pragma mark - 点击超链接回调
//- (void)attributedLabel:(TTTAttributedLabel *)label
//   didSelectLinkWithURL:(NSURL *)url {
//    if( [[url absoluteString] isEqualToString:ADD_CREDIT_URL] ) {
//        [self addCreditsViewShow];
//    }
//}

#pragma mark - 表情按钮选择回调
- (void)selectedChanged:(id)sender {

    [self.textView endEditing:YES];
    UIButton *emotionBtn = (UIButton *)sender;
    if( emotionBtn.selected == YES ) {
        // 弹出底部emotion的键盘
        [self showEmotionView];
        
    } else {
        // 切换成系统的的键盘
        [self showKeyboardView];
    }
}

#pragma mark - 普通表情选择回调
- (void)chatEmotionChooseView:(ChatEmotionChooseView *)chatEmotionChooseView didSelectNomalItem:(NSInteger)item {
    if( self.textView.text.length < maxInputCount ) {
        // 插入表情到输入框
        ChatEmotion* emotion = [self.emotionArray objectAtIndex:item];
        [self.textView insertEmotion:emotion];
    }
}

#pragma mark - 表情键盘选择回调
- (NSUInteger)pagingViewCount:(ChatEmotionKeyboardView *)chatEmotionKeyboardView {
    return 2;
}

- (Class)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView classForIndex:(NSUInteger)index {
    Class cls = nil;
    switch(index) {
        case 0:{
            cls = [ChatEmotionChooseView class];
            // 普通表情
            //            cls = [ChatEmotionChooseView class];
        }break;
            
        case 1:{
            // 高级表情
            cls = [ChatEmotionChooseView class];
        }break;
            
        default:{
            cls = [UIView class];
        }break;
    }
    return cls;
}

- (UIView *)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView pageViewForIndex:(NSUInteger)index {
    UIView* view = nil;
    switch(index) {
        case 0:{
            // 普通表情
            view = self.chatNomalEmotionView;
        }break;
            
        case 1:{
            // 高级表情
            view = self.chatFriendlyChooseView;
        }break;
            
        default:{
            view = [[UIView alloc] init];
        }break;
    }
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    view.frame = frame;
    
    return view;
}

- (void)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    switch(index) {
        case 0:{
            // 普通表情
            [self.chatNomalEmotionView reloadData];
            
        }break;
        case 1:{
            // 高级表情
            [self.chatFriendlyChooseView reloadData];
            
        }break;
        default:{
        }break;
    }
}

- (void)chatEmotionKeyboardView:(ChatEmotionKeyboardView *)chatEmotionKeyboardView didShowPageViewForDisplay:(NSUInteger)index {
    switch (index) {
        case 0:{

        
        } break;
        case 1:{
        }break;
        default:
            break;
    }
    
}

#pragma mark - 发送消息逻辑
/**
 *  重发消息
 *
 *  @param index 消息体
 */
- (void)reSendMsg:(NSInteger)index {
    if( index < self.msgArray.count ) {
//        Message* msg = [self.msgArray objectAtIndex:index];
        
        // 删除旧信息, 只改数据
//        [self.liveChatManager removeHistoryMessage:self.womanId msgId:msg.msgId];
        [self.msgArray removeObjectAtIndex:index];
        
        // 刷新列表
        [self.tableView beginUpdates];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        
        NSMutableArray *warnningMsg = [NSMutableArray array];
//        for (Message* msg in self.msgArray) {
//            if (msg.type == MessageTypeWarningTips) {
//                [self.liveChatManager removeHistoryMessage:self.womanId msgId:msg.msgId];
//                [warnningMsg addObject:msg];
//            }
//        }
        NSMutableArray *warnningMsgIndex = [NSMutableArray array];
        for (int i = 0; i< self.msgArray.count;i++ ) {
//               Message* msg = [self.msgArray objectAtIndex:i];
//            if (msg.type == MessageTypeWarningTips) {
//                  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                [warnningMsgIndex addObject:indexPath];
//            }
        }
        [self.msgArray removeObjectsInArray:warnningMsg];
          [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:warnningMsgIndex withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];

        
        // 重新发送
//        switch (msg.type) {
//            case MessageTypeText:{
//                [self sendMsg:msg.text];
//            }break;
//            case MessageTypePhoto:{
//                [self sendPhoto:msg.liveChatMsgItemObject.secretPhoto.srcFilePath];
//            }break;
//            case MessageTypeSmallEmotion:{
//                [self sendSmallEmotion:msg.liveChatMsgItemObject.magicIconMsg.magicIconId];
//
//            }break;
//            case MessageTypeLargeEmotion:{
//                [self sendLargeEmotion:msg.liveChatMsgItemObject.emotionMsg.emotionId];
//            }break;
//            case MessageTypeVoice:
//            {
//                [self sendVoice:msg.liveChatMsgItemObject.voiceMsg.filePath time:msg.liveChatMsgItemObject.voiceMsg.timeLength];
//            }break;
//            default:
//                break;
//        }
    }
    
}

//判断内容是否全部为空格  yes 全部为空格  no 不是
- (BOOL)isEmpty:(NSString *) str {
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}
/**
 *  发送文本
 *
 *  @param text 发送文本
 */
- (void)sendMsg:(NSString* )text {
    if( text.length > 200 ) {
        NSString* tips = NSLocalizedStringFromSelf(@"Local_Error_Tips_200_Input_Limited");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        alertView.tag = AlertType200Limited;
        [alertView show];
        return;
    }
    
    if ([self isEmpty:text]) {
        [self.textView setText:@""];
        [self.textView setNeedsDisplay];
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedStringFromSelf(@"Send_Error_Tips_Space") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    //去除掉首尾的空白字符和换行字符
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
   
    // 发送消息
//    LiveChatMsgItemObject* msg = [self.liveChatManager sendTextMsg:self.womanId text:text];
//    if( msg != nil ) {
//        NSLog(@"ChatViewController::sendMsg( 发送文本消息 : %@, msgId : %ld )", text, (long)msg.msgId);
//        
//        // 更新最近联系人数据
//        [self updateRecents:msg];
//        
//    } else {
//        NSLog(@"ChatViewController::sendMsg( 发送文本消息 : %@, 失败 )", text);
//    }
//    
//    // 刷新输入框
    [self.textView setText:@""];
//    // 刷新默认提示
    [self.textView setNeedsDisplay];
//
//    // 刷新列表
//    // [self reloadData:YES scrollToEnd:YES animated:YES];
//    [self insertData:msg scrollToEnd:YES animated:YES];
}

#pragma mark - 重新加载消息到界面
/**
 *  重新加载消息到界面
 *
 *  @param isReloadView 是否刷新界面
 */
- (void)reloadData:(BOOL)isReloadView scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
    // 数据填充
    
//    NSMutableArray* dataArray = [NSMutableArray array];
//    NSArray* array = [self.liveChatManager getMsgsWithUser:self.womanId];
//    for(LiveChatMsgItemObject* msg in array) {
//        Message* item = [self reloadMessageFromLiveChatMsgItemObject:msg];
//        [dataArray addObject:item];
//    }
//    if(isReloadView) {
//        
//        self.msgArray = dataArray;
//        
//        [self.tableView reloadData];
//        
//        if( scrollToEnd ) {
//            [self scrollToEnd:animated];
//        }
//    }
}

/**
 *  插入加载消息到界面
 *
 *  @param scrollToEnd 是否刷新界面
 */
//- (void)insertData:(LiveChatMsgItemObject *)object scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
//    Message* item = [self reloadMessageFromLiveChatMsgItemObject:object];
//    [self.msgArray addObject:item];
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
//    
//    if ([object.toId isEqualToString:self.womanId]) {
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"didChatList" object:nil];
//    }
//    
//    if( scrollToEnd ) {
//        [self scrollToEnd:animated];
//    }
//}

/**
 *  更新消息数据
 *
 *  @param scrollToEnd 是否刷新界面
 */
//- (void)updataMessageData:(LiveChatMsgItemObject *)object scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated
//{
//    @synchronized (self) {
//            //为了兼容cell插入数据时动画不冲突，延迟执行刷新
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                 Message* item = [self reloadMessageFromLiveChatMsgItemObject:object];
//                NSInteger count = 0;
//                for (int i = 0; i < self.msgArray.count; i++) {
//                    Message* msg = self.msgArray[i];
//                    if (msg.msgId == object.msgId) {
//                        count = i;
//                        break;
//                    }
//                }
//                if (self.msgArray.count > 0) {
//                    [self.msgArray removeObjectAtIndex:count];
//                }
//                [self.msgArray insertObject:item atIndex:count];
//                
//                if (self.msgArray.count > 1) {
//                    [self.tableView beginUpdates];
//                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:count inSection:0]]  withRowAnimation:UITableViewRowAnimationNone];
//                    [self.tableView endUpdates];
//                }
//                else
//                {
//                    [self.tableView reloadData];
//                }
//
//                
//                if( scrollToEnd ) {
//                    [self scrollToEnd:animated];
//                }
//            });
//    }
//}

/**
 *  Message赋值逻辑
 *
 *  @param msg
 */
//- (Message *)reloadMessageFromLiveChatMsgItemObject:(LiveChatMsgItemObject *)msg
//{   Message *item = [[Message alloc] init];
//    item.liveChatMsgItemObject = msg;
//    item.msgId = msg.msgId;
//    if( msg.msgType == LCMessageItem::MessageType::MT_Custom ) {
//        // 自定义消息
//        Message* custom = [self.msgCustomDict valueForKey:[NSString stringWithFormat:@"%ld", (long)msg.msgId]];
//        if( custom != nil ) {
//            item = [custom copy];
//        }
//        
//    } else {
//        // 其他
//        
//        // 方向
//        switch (msg.sendType) {
//            case LCMessageItem::SendType::SendType_Send:{
//                // 发出去的消息
//                item.sender = MessageSenderSelf;
//                
//            }break;
//            case LCMessageItem::SendType::SendType_Recv:{
//                // 接收到的消息
//                item.sender = MessageSenderLady;
//                
//            }break;
//            case LCMessageItem::SendType::SendType_System:{
//                // 系统消息
//            }break;
//            default:
//                break;
//        }
//        
//        // 类型
//        switch (msg.msgType) {
//            case LCMessageItem::MessageType::MT_Text:{
//                // 文本
//                item.type = MessageTypeText;
//                item.text = msg.textMsg.displayMsg;
//                item.attText = [self parseMessageTextEmotion:item.text font:[UIFont systemFontOfSize:TextMessageFontSize]];
//                
//            }break;
//            case LCMessageItem::MessageType::MT_System:{
//                item.type = MessageTypeSystemTips;
//                
//                switch (msg.systemMsg.codeType) {
//                    case LCSystemItem::MESSAGE:{
//                        // 普通系统消息
//                        item.text = msg.systemMsg.message;
//                        
//                    }break;
//                    case LCSystemItem::TRY_CHAT_END:{
//                        // 试聊结束消息
//                        item.text = msg.systemMsg.message;
//                        item.text = NSLocalizedStringFromSelf(@"Tips_Your_Free_Chat_Is_Ended");
//                        
//                    }break;
//                    case LCSystemItem::NOT_SUPPORT_TEXT:{
//                        // 不支持文本消息
//                        item.text = msg.systemMsg.message;
//                        item.text = NSLocalizedStringFromSelf(@"Tips_Text_Not_Support");
//                        
//                    }break;
//                    case LCSystemItem::NOT_SUPPORT_EMOTION:{
//                        // 试聊券系统消息
//                        item.text = msg.systemMsg.message;
//                        item.text = NSLocalizedStringFromSelf(@"Tips_Emotion_Not_Support");
//                        
//                    }break;
//                    case LCSystemItem::NOT_SUPPORT_VOICE:{
//                        // 不支持语音消息
//                        item.text = msg.systemMsg.message;
//                        item.text = NSLocalizedStringFromSelf(@"Tips_Voice_Not_Support");
//                        
//                    }break;
//                    case LCSystemItem::NOT_SUPPORT_PHOTO:{
//                        // 不支持私密照消息
//                        item.text = msg.systemMsg.message;
//                        item.text = NSLocalizedStringFromSelf(@"Tips_Photo_Not_Support");
//                        
//                    }break;
//                    case LCSystemItem::NOT_SUPPORT_MAGICICON:{
//                        // 不支持小高表消息
//                        item.text = msg.systemMsg.message;
//                        item.text = NSLocalizedStringFromSelf(@"Tips_MagicIcon_Not_Support");
//                        
//                    }break;
//                    default:
//                        break;
//                }
//                
//                item.attText = [self parseMessage:item.text font:[UIFont systemFontOfSize:SystemMessageFontSize] color:MessageGrayColor];
//                
//            }break;
//            case LCMessageItem::MessageType::MT_Warning:{
//                item.type = MessageTypeWarningTips;
//                switch (msg.warningMsg.codeType) {
//                    case LCWarningItem::CodeType::NOMONEY:{
//                        item.text = msg.warningMsg.message;
//                        NSString* tips = NSLocalizedStringFromSelf(@"Warning_Error_Tips_No_Money");
//                        NSString* linkMessage = NSLocalizedStringFromSelf(@"Tips_Add_Credit");
//                        item.attText = [self parseNoMomenyWarningMessage:tips linkMessage:linkMessage font:[UIFont systemFontOfSize:WarningMessageFontSize] color:MessageGrayColor];
//                    }break;
//                    default:{
//                        item.text = msg.warningMsg.message;
//                        item.attText = [self parseMessage:item.text font:[UIFont systemFontOfSize:SystemMessageFontSize] color:MessageGrayColor];
//                        
//                    }break;
//                        
//                }
//            }break;
//            case LCMessageItem::MessageType::MT_Photo:{
//                item.type = MessageTypePhoto;
//                item.secretPhotoImage = [UIImage imageNamed:@"Chat-SecretPlaceholder"];
//                
//                // 私密照
//                switch (item.sender) {
//                    case MessageSenderLady:{
//                        if (msg.secretPhoto) {
//
//                        }
//                    }break;
//                    case MessageSenderSelf:{
//                        if (msg.secretPhoto) {
//
//                        }
//                    }
//                        
//                    default:
//                        break;
//                }
//                
//            }break;
//                //语音类型
//            case LCMessageItem::MessageType::MT_Voice:{
//                item.type = MessageTypeVoice;
//                
//                //如果本地没有语音文件就自动下载
//                if (item.liveChatMsgItemObject.voiceMsg.filePath.length == 0) {
//                    [self.liveChatManager GetVoice:self.womanId msgId:(int)item.msgId];
//                }
//                
//                switch (item.sender) {
//                    case MessageSenderLady:
//                    {
//                        //标记是否已读
//                        item.liveChatMsgItemObject.voiceMsg.isRead = [self.voiceManager voiceMessageIsRead:item.liveChatMsgItemObject.voiceMsg.voiceId];
//                    }break;
//                    default:
//                        break;
//                }
//            }break;
//            case LCMessageItem::MessageType::MT_Emotion:{
//                item.type = MessageTypeLargeEmotion;
//                switch (item.sender) {
//                    case MessageSenderLady:
//                    case MessageSenderSelf:{
//                        NSString* emotionId = msg.emotionMsg.emotionId;
//                        
//                        // 设置缩略图
//                        if( msg.emotionMsg.imagePath.length > 0 ) {
//                            NSString* imagePath = msg.emotionMsg.imagePath;
//                            item.emotionDefault = [self getEmotionImageFromCache:emotionId imagePath:imagePath];
//                        }else {
//                            [self.liveChatManager GetEmotionImage:msg.emotionMsg.emotionId];
//                        }
//                        
//                        // 设置动画图片
//                        if (msg.emotionMsg.playBigImages.count > 0) {
//                            item.emotionAnimationArray = [self getEmotionImageArrayFromCache:emotionId imagePathArray:msg.emotionMsg.playBigImages];
//                        } else {
//                            [self.liveChatManager GetEmotionPlayImage:emotionId];
//                        }
//                        
//                    }break;
//                        
//                    default:
//                        break;
//                }
//            }break;
//            case LCMessageItem::MessageType::MT_MagicIcon:{
//                item.type = MessageTypeSmallEmotion;
//                switch (item.sender) {
//                    case MessageSenderLady:
//                    case MessageSenderSelf:{
//                        NSString* emotionId = msg.magicIconMsg.magicIconId;
//                        // 设置缩略图
//                        if( msg.magicIconMsg.thumbPath.length > 0 ) {
//                            NSString* imagePath = msg.magicIconMsg.thumbPath;
//                            item.emotionDefault = [self getSmallThumbEmotionImageFromCache:emotionId imagePath:imagePath];
//                        }
//                        else
//                        {
//                            if (emotionId.length > 0) {
//                                [self.liveChatManager GetMagicIconThumbImage:emotionId];
//                            }
//                        }
//                        
//                    }break;
//                        
//                    default:
//                        break;
//                }
//            }break;
//            default:
//                break;
//        }
//    
//        // 状态
//        switch (msg.statusType) {
//            case LCMessageItem::StatusType::StatusType_Processing:{
//                // 处理中
//                item.status = MessageStatusProcessing;
//            }break;
//            case LCMessageItem::StatusType::StatusType_Fail:{
//                // 失败
//                item.status = MessageStatusFail;
//            }break;
//            case LCMessageItem::StatusType::StatusType_Finish:{
//                // 完成
//                item.status = MessageStatusFinish;
//            }break;
//                
//            default:
//                break;
//        }
//    }
//    
//    return item;
//}

/**
 *  消息列表滚动到最底
 */
- (void)scrollToEnd:(BOOL)animated {
    NSInteger count = [self.tableView numberOfRowsInSection:0];
    if( count > 0 ) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

//- (Message* )insertCustomMessage {
//    // 自定义消息类型
//    LiveChatMsgItemObject* msg = [[LiveChatMsgItemObject alloc] init];
//    msg.msgType = LCMessageItem::MessageType::MT_Custom;
//    msg.createTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
//    
//    // 无用代码
//    msg.customMsg = [[LiveChatCustomItemObject alloc] init];
//    
//    // 记录自定义消息
//    Message* custom = [[Message alloc] init];
//    
//    NSInteger msgId = [self.liveChatManager insertHistoryMessage:self.womanId msg:msg];
//    custom.msgId = msgId;
//    
//    [self.msgCustomDict setValue:custom forKey:[NSString stringWithFormat:@"%ld", (long)msgId]];
//    
//    return custom;
//}

//插入非法警告消息
- (void)insertWaringMessage {
    // 自定义消息类型
//    LiveChatMsgItemObject* msg = [[LiveChatMsgItemObject alloc] init];
//    msg.msgType = LCMessageItem::MessageType::MT_Warning;
//    msg.createTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
//    msg.warningMsg = [[LiveChatWarningItemObject alloc]init];
//    msg.warningMsg.message = NSLocalizedStringFromSelf(@"Send_Error_Tips_Illegal");
//    [self.liveChatManager insertHistoryMessage:self.womanId msg:msg];
//    [self insertData:msg scrollToEnd:YES animated:YES];
}

/**
 *  清空自定义消息
 */
- (void)clearCustomMessage {
//    for(NSString *key in self.msgCustomDict) {
//        Message* msg = [self.msgCustomDict valueForKey:key];
//        [self.liveChatManager removeHistoryMessage:self.womanId msgId:msg.msgId];
//    }
    
}

- (void)outCreditEvent:(NSInteger)index {
    // 帐号余额不足, 弹出买点
    NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_No_Money");
    if ( [[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:tips preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:ok];
        [self presentViewController:alertVc animated:NO completion:nil];
        
    }else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        alertView.tag = index;
        [alertView show];
    }
}

/**
 *  错误消息处理
 *
 *  @param index 消息下标
 */
- (void)handleErrorMsg:(NSInteger)index {
//    Message* msg = [self.msgArray objectAtIndex:index];
//    LiveChatMsgProcResultObject* procResult = msg.liveChatMsgItemObject.procResult;
//    
//    if( procResult ) {
//        switch (procResult.errType) {
//            case LCC_ERR_FAIL:
////            {
//                // php错误
////                if( [procResult.errNum isEqualToString:LIVECHAT_NO_MONEY] ) {
////                    [self outCreditEvent:index];
////                } else {
//                    // 直接提示错误信息
////                    NSString* tips = NSLocalizedStringFromErrorCode(procResult.errNum);
////                    if( tips.length == 0 ) {
////                        tips = procResult.errMsg;
////                    }
////                    
////                    if( tips.length == 0 ) {
////                        tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Other");
////                    }
//                    // 弹出重试
////                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
////                    
////                    alertView.tag = index;
////                    [alertView show];
////                }
////            }break;
//            case LCC_ERR_UNBINDINTER:// 女士的翻译未将其绑定
//            case LCC_ERR_SIDEOFFLINE:// 对方不在线
//            case LCC_ERR_NOTRANSORAGENTFOUND:// 没有找到翻译或机构
//            case LCC_ERR_BLOCKUSER:// 对方为黑名单用户（聊天）
//            case LCC_ERR_NOMONEY:
//            {
//                // 重新获取当前女士用户状态
//                LiveChatUserItemObject* user = [self.liveChatManager getUserWithId:self.womanId];
//                if( user && user.statusType == USTATUS_ONLINE ) {
//                    // 弹出重试
//                    NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Retry");
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
//                    
//                    alertView.tag = index;
//                    [alertView show];
//                    
//                } else {
//                    // 弹出不在线
//                    NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Offline");
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:NSLocalizedString(@"Send mail", nil),nil];
//                    alertView.tag = index;
//                    [alertView show];
//                }
//                
//            }break;
////            case LCC_ERR_NOMONEY:
////            {
//////                [self outCreditEvent:index];
////                NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Retry");
////                // 弹出重试
////                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
////                
////                alertView.tag = index;
////                [alertView show];
////            }break;
//            default:{
//                // 其他未处理错误
//                NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Other");
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
//                
//                alertView.tag = index;
//                [alertView show];
//                
//            }break;
//        }
//    }
}

#pragma mark - 表情逻辑
/**
 加载普通表情
 */
- (void)reloadEmotion {
    // 读取表情配置文件
    NSString *emotionPlistPath = [[NSBundle mainBundle] pathForResource:@"EmotionList" ofType:@"plist"];
    NSArray* emotionFileArray = [[NSArray alloc] initWithContentsOfFile:emotionPlistPath];
    
    // 初始化普通表情文件名字
    NSMutableArray* emotionArray = [NSMutableArray array];
    NSMutableDictionary* emotionDict = [NSMutableDictionary dictionary];
    
    ChatEmotion* emotion = nil;
    UIImage* image = nil;
    NSString* imageFileName = nil;
    NSString* imageName = nil;
    
    for(NSDictionary* dict in emotionFileArray) {
        imageFileName = [dict objectForKey:@"name"];
        image = [UIImage imageNamed:imageFileName];
        if( image != nil ) {
            imageName = [self parseEmotionTextByImageName:imageFileName];
            emotion = [[ChatEmotion alloc] initWithTextImage:imageName image:image];
            
            [emotionDict setObject:emotion forKey:imageName];
            [emotionArray addObject:emotion];
        }
    }
    
    self.emotionDict = emotionDict;
    self.emotionArray = emotionArray;
}

#pragma mark - 消息列表文本解析
/**
 *  根据表情文件名字生成表情协议名字
 *
 *  @param imageName 表情文件名字
 *
 *  @return 表情协议名字
 */
- (NSString* )parseEmotionTextByImageName:(NSString* )imageName {
    NSMutableString* resultString = [NSMutableString stringWithString:imageName];
    
    NSRange range = [resultString rangeOfString:@"img"];
    if( range.location != NSNotFound ) {
        [resultString replaceCharactersInRange:range withString:@"[img:"];
        [resultString appendString:@"]"];
    }
    
    return resultString;
}

/**
 *  解析消息表情和文本消息
 *
 *  @param text 普通文本消息
 *  @param font        字体
 *  @return 表情富文本消息
 */
- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRange range;
    NSRange endRange;
    NSRange valueRange;
    NSRange replaceRange;
    
    NSString* emotionOriginalString = nil;
    NSAttributedString* emotionAttString = nil;
    ChatTextAttachment *attachment = nil;
    
    NSString* findString = attributeString.string;
    
    // 替换img
    while (
           (range = [findString rangeOfString:@"[img:"]).location != NSNotFound &&
           (endRange = [findString rangeOfString:@"]"]).location != NSNotFound &&
           range.location < endRange.location
           ) {
        // 增加表情文本
        attachment = [[ChatTextAttachment alloc] init];
        attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
        
        // 解析表情字串
        valueRange = NSMakeRange(range.location, NSMaxRange(endRange) - range.location);
        // 原始字符串
        emotionOriginalString = [findString substringWithRange:valueRange];

        ChatEmotion* emotion = [self.emotionDict objectForKey:emotionOriginalString];
        if( emotion != nil ) {
            attachment.image = emotion.image;
        }
        
        attachment.text = emotionOriginalString;
        // 生成表情富文本
        emotionAttString = [NSAttributedString attributedStringWithAttachment:attachment];
        // 替换普通文本为表情富文本
        replaceRange = NSMakeRange(range.location, NSMaxRange(endRange) - range.location);
        [attributeString replaceCharactersInRange:replaceRange withAttributedString:emotionAttString];
        // 替换查找文本
        findString = attributeString.string;
    }
    
    [attributeString addAttributes:@{NSFontAttributeName : font} range:NSMakeRange(0, attributeString.length)];
    
    return attributeString;
}

/**
 *  解析普通消息
 *
 *  @param text 普通文本
 *  @param font        字体
 *  @return 普通富文本消息
 */
- (NSAttributedString* )parseMessage:(NSString* )text font:(UIFont* )font color:(UIColor *)textColor{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    return attributeString;
}

/**
 *  解析没钱警告消息
 *
 *  @param text 没钱警告消息
 *  @param linkMessage 可以点击的文字
 *  @param font        字体
 *  @return 没钱富文本警告消息
 */
- (NSAttributedString* )parseNoMomenyWarningMessage:(NSString* )text linkMessage:(NSString* )linkMessage font:(UIFont* )font color:(UIColor *)textColor{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)];
    
    
    ChatTextAttachment *attachment = [[ChatTextAttachment alloc] init];
    attachment.text = linkMessage;
    attachment.url = [NSURL URLWithString:ADD_CREDIT_URL];
    attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
    NSMutableAttributedString *attributeLinkString = [[NSMutableAttributedString alloc] initWithString:linkMessage];
    [attributeLinkString addAttributes:@{
                                         NSFontAttributeName : font,
                                         NSAttachmentAttributeName : attachment,
                                         } range:NSMakeRange(0, attributeLinkString.length)];
    
    [attributeString appendAttributedString:attributeLinkString];
    return attributeString;
}
#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = self.msgArray.count;
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if( indexPath.row < 0 || indexPath.row >= self.msgArray.count ) {
        return height;
    }
//    // 数据填充
//    Message* item = [self.msgArray objectAtIndex:indexPath.row];
//    switch (item.type) {
//        case MessageTypeSystemTips: {
//            // 系统消息
//            CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatSystemTipsTableViewCell cellHeight:self.tableView.frame.size.width detailString:item.attText]);
//            height = viewSize.height;
//        }break;
//        case MessageTypeWarningTips:{
//            // 警告消息
//            // 系统消息
//            CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatSystemTipsTableViewCell cellHeight:self.tableView.frame.size.width detailString:item.attText]);
//            height = viewSize.height;
//        }break;
//        case MessageTypeText:{
//            // 文本
//            switch (item.sender) {
//                case MessageSenderLady: {
//                    // 对方
//                    CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatTextLadyTableViewCell cellHeight:self.tableView.frame.size.width detailString:item.attText]);
//                    height = viewSize.height;
//                }break;
//                case MessageSenderSelf:{
//                    // 自己
//                    CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatTextSelfTableViewCell cellHeight:self.tableView.frame.size.width detailString:item.attText]);
//                    height = viewSize.height;
//                }break;
//                default: {
//                }break;
//            }
//        }break;
//        case MessageTypeCoupon:{
//            // 试聊券
//            CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatCouponTableViewCell cellHeight]);
//            height = viewSize.height;
//        }break;
//          default:
//              break;
//            }
//        }break;
//        default: {
//        }break;
//    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    if( indexPath.row < 0 || indexPath.row >= self.msgArray.count ) {
        result = [tableView dequeueReusableCellWithIdentifier:@""];
        if( !result ) {
            result = [[UITableViewCell alloc] init];
        }
    }
    // 数据填充
//    Message* item = [self.msgArray objectAtIndex:indexPath.row];
//    switch (item.type) {
//        case MessageTypeSystemTips: {
//            // 系统提示
//            ChatSystemTipsTableViewCell* cell = [ChatSystemTipsTableViewCell getUITableViewCell:tableView];
//            result = cell;
//            cell.detailLabel.attributedText = item.attText;
//            cell.detailLabel.delegate = self;
//            [item.attText enumerateAttributesInRange:NSMakeRange(0, item.attText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//                ChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
//                if( attachment && attachment.url != nil ) {
//                    [cell.detailLabel addLinkToURL:attachment.url withRange:range];
//                }
//            }];
//        }break;
//        case MessageTypeWarningTips:{
//            // 警告消息
//            ChatSystemTipsTableViewCell* cell = [ChatSystemTipsTableViewCell getUITableViewCell:tableView];
//            result = cell;
//            cell.detailLabel.attributedText = item.attText;
//            cell.detailLabel.delegate = self;
//            [item.attText enumerateAttributesInRange:NSMakeRange(0, item.attText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//                ChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
//                if( attachment && attachment.url != nil ) {
//                    [cell.detailLabel addLinkToURL:attachment.url withRange:range];
//                }
//            }];
//        }break;
//        case MessageTypeText:{
//            // 文本
//            switch (item.sender) {
//                case MessageSenderLady: {
//                    // 接收到的消息
//                    ChatTextLadyTableViewCell* cell = [ChatTextLadyTableViewCell getUITableViewCell:tableView];
//                    result = cell;
//                    // 用于点击重发按钮
//                    result.tag = indexPath.row;
//                    cell.detailLabel.attributedText = item.attText;
//                }break;
//                case MessageSenderSelf:{
//                    // 发出去的消息
//                    ChatTextSelfTableViewCell* cell = [ChatTextSelfTableViewCell getUITableViewCell:tableView];
//                    result = cell;
//                    // 用于点击重发按钮
//                    result.tag = indexPath.row;
//                    cell.delegate = self;
//                    cell.detailLabel.attributedText = item.attText;
//                    switch (item.status) {
//                        case MessageStatusProcessing: {
//                            // 发送中
//                            cell.activityIndicatorView.hidden = NO;
//                            [cell.activityIndicatorView startAnimating];
//                            cell.retryButton.hidden = YES;
//                        }break;
//                        case MessageStatusFinish: {
//                            // 发送成功
//                            cell.activityIndicatorView.hidden = YES;
//                            cell.retryButton.hidden = YES;
//                        }break;
//                        case MessageStatusFail:{
//                            // 发送失败
//                            cell.activityIndicatorView.hidden = YES;
//                            cell.retryButton.hidden = NO;
//                            cell.delegate = self;
//                        }break;
//                        default: {
//                            // 未知
//                            cell.activityIndicatorView.hidden = YES;
//                            cell.retryButton.hidden = YES;
//                            cell.delegate = self;
//                        }break;
//                    }
//                }break;
//                default: {
//                    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@""];
//                    result = cell;
//                }break;
//            }
//        }break;
//            default:
//               break;
//            }
//        }break;
//        case MessageTypeCoupon:{
//            // 试聊券
//            ChatCouponTableViewCell *cell = [ChatCouponTableViewCell getUITableViewCell:tableView];
//            result = cell;
//        }break;
//                default:
//                    break;
//            }
//        }
//        default: {
//        }break;
//    }
    
    if( !result ) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@""];
        if( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        }
        result = cell;
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self closeAllInputView];
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    BOOL bFlag = NO;
    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];
    
    if(height != 0) {
        // 弹出键盘
        // 增加加速度
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
        self.inputMessageViewBottom.constant = -height;
        bFlag = YES;
//        [self scrollToEnd:YES];
    } else {
        // 收起键盘
        self.inputMessageViewBottom.constant = 0;
    }

    [UIView animateWithDuration:duration animations:^{
        // Make all constraint changes here, Called on parent view
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if( bFlag ) {
            [self scrollToEnd:YES];
        }
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    self.keyboardHeight = keyboardRect.size.height;
    // 从表情键盘切换成系统键盘,保存普通表情的富文本属性
    self.emotionAttributedString = self.textView.attributedText;
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

#pragma mark - 输入回调

- (void)textViewDidChange:(UITextView *)textView {
    // 超过字符限制
    NSString *toBeString = textView.text;
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (position) {
        if (toBeString.length > maxInputCount) {
            // 取出之前保存的属性
           textView.attributedText = self.emotionAttributedString;
            
        }else {
            // 记录当前的富文本属性
            self.emotionAttributedString = textView.attributedText;
        }
    }
}



- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // 增加手势
    [self addSingleTap];
    // 切换所有按钮到系统键盘状态
    self.emotionBtn.selected = NO;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL result = YES;
    
    if( [text containEmoji] ) {
        // 系统表情，不允许输入
        result = NO;
    }
    else if ([text isEqualToString:@"\n"]) {
        // 输入回车，即按下send，不允许输入
        [self sendMsgAction:nil];
        result = NO;
    }
    else {
        // 判断是否超过字符限制
        NSInteger strLength = textView.text.length - range.length + text.length;
        if (strLength >= maxInputCount && text.length >= range.length) {
            // 判断是否删除字符
            if ('\000' != [text UTF8String][0] && ![text isEqualToString:@"\b"]) {
                // 非删除字符，不允许输入
                result = NO;
            }
        }
    }
    return result;
}

#pragma mark - 输入栏高度改变回调
- (void)textViewChangeHeight:(ChatTextView * _Nonnull)textView height:(CGFloat)height {
    if( height < INPUTMESSAGEVIEW_MAX_HEIGHT ) {
        self.inputMessageViewHeight.constant = height + 10;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView setNeedsDisplay];
    });
}

@end
