//
//  LSChatViewController.m
//  livestream
//
//  Created by Calvin on 2018/6/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSChatViewController.h"
#import "LSChatTableView.h"
#import "LSChatTextView.h"
#import "LSMessage.h"
#import "LSChatTextAttachment.h"
#import "LSChatEmotion.h"
#import "LSChatEmotionKeyboardView.h"
#import "LSLiveStandardEmotionView.h"
#import "LSChatEmotionViewController.h"
#import "MJRefresh.h"
#import "LSAddCreditsViewController.h"
#import "AnchorPersonalViewController.h"
#import "LSRoomUserInfoManager.h"
#import "LiveModule.h"
#import "LSImManager.h"
#import "LSSendMessageManager.h"

#define INPUTMESSAGEVIEW_MAX_HEIGHT 80
#define INPUTMESSAGEVIEW_NORMAL_HEIGHT 56
#define MAXInputCount 240
#define ADD_CREDIT_URL @"ADD_CREDIT_URL"
#define ISHAVEANCHORID self.anchorId.length > 0 ? YES : NO
#define sx_deviceVersion [[[UIDevice currentDevice] systemVersion] floatValue]

@interface LSChatViewController () <LSChatTableViewDelegate, LSChatTextViewDelegate, LSCheckButtonDelegate, LSChatEmotionKeyboardViewDelegate,
                                    LSLiveStandardEmotionViewDelegate, UITextViewDelegate, LMMessageManagerDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate,
                                    LSChatEmotionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet LSChatTableView *tableView;
@property (nonatomic, strong) MJRefreshNormalHeader *refresHeader;
// 发送栏
@property (weak, nonatomic) IBOutlet UIView *inputMessageView;
// 输入框
@property (weak, nonatomic) IBOutlet LSChatTextView *textView;
// 表情按钮
@property (weak, nonatomic) IBOutlet LSCheckButton *emotionBtn;
// 输入框高度约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewHeight;
// 输入框底部约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputMessageViewBottom;
/**
 主播ID
 */
@property (nonatomic, copy) NSString *anchorId;
// 文字的富文本属性
@property (nonatomic, copy) NSAttributedString *emotionAttributedString;
// 单击收起输入控件手势
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
// 消息数组
@property (nonatomic, strong) NSMutableArray<LSMessage *> *msgArray;
// 表情列表
@property (nonatomic, retain) NSArray *emotionArray;
// 表情列表(用于查找)
@property (nonatomic, retain) NSDictionary *emotionDict;
// 表情管理类
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;
// 表情管理控制器
@property (nonatomic, strong) LSChatEmotionViewController *emotionVC;

// 私密消息管理器
@property (nonatomic, strong) LSPrivateMessageManager *messageManager;
// 是否可以下拉刷新
@property (nonatomic, assign) BOOL isCanGetMore;

@property (nonatomic, strong) LSSendMessageManager *sendMessageManager;

@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

@end

@implementation LSChatViewController

- (void)dealloc {
    NSLog(@"LSChatViewController::dealloc()");

    [[LSImManager manager] removeDelegate:self];
    [[LSImManager manager].client removeDelegate:self];

    [self.messageManager.client removeDelegate:self];
}

+ (instancetype)initChatVCWithAnchorId:(NSString *)anchorId {
    LSChatViewController *vc = [[LSChatViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[LSImManager manager] addDelegate:self];
    [[LSImManager manager].client addDelegate:self];

    self.roomUserInfoManager = [LSRoomUserInfoManager manager];

    self.tableView.tableViewDelegate = self;

    self.msgArray = [NSMutableArray array];
    self.emotionArray = [NSMutableArray array];
    self.emotionDict = [NSDictionary dictionary];

    // 初始化表情管理器
    self.emotionManager = [LSChatEmotionManager emotionManager];

    // 消息文本管理器
    self.messageManager = [LSPrivateMessageManager manager];
    [self.messageManager.client addDelegate:self];

    // 发送消息文本管理器
    self.sendMessageManager = [[LSSendMessageManager alloc] init];

    [self setupInputView];
    [self setupEmotionInputView];

    if (ISHAVEANCHORID) {
        WeakObject(self, weakSelf);
        self.isCanGetMore = [self.messageManager isHasMorePrivateMsgWithUserId:self.anchorId];
        [self getLocalMessage:^{
            [weakSelf refreshPrivateMsgWithUserId:self.anchorId];
        }];
    }
    // 获取是否可以上拉
    [self setTheTableViewMJHeadr:self.isCanGetMore];
}

- (void)setTheTableViewMJHeadr:(BOOL)isSet {
    if (isSet) {
        if (!self.tableView.mj_header) {
            [self.tableView setMj_header:self.refresHeader];
        }
    } else {
        self.tableView.mj_header = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // 移除下拉刷新控件 防止控制器未释放
    self.refresHeader = nil;
    self.tableView.mj_header = nil;

    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];

    if (self.anchorId.length > 0) {
        [self.roomUserInfoManager getUserInfo:self.anchorId
                                finishHandler:^(LSUserInfoModel *_Nonnull item) {
                                    // 设置聊天标题
                                    [self setupTitleButton:item.nickName];
                                }];
    }
}

- (void)setupTitleButton:(NSString *)title {
    UIButton *titleBtn = [[UIButton alloc] init];
    [titleBtn setTitle:title forState:UIControlStateNormal];
    [titleBtn setTitle:title forState:UIControlStateHighlighted];
    [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    titleBtn.titleLabel.font = [UIFont systemFontOfSize:19];
    [titleBtn addTarget:self action:@selector(enterAnchorFetail) forControlEvents:UIControlEventTouchUpInside];
    titleBtn.frame = CGRectMake(0, 0, 200, 0);
    // 标题
    self.navigationItem.titleView = titleBtn;
}

- (void)enterAnchorFetail {
    if (self.anchorId.length > 0) {
        AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
        listViewController.anchorId = self.anchorId;
        listViewController.enterRoom = 1;
        [self.navigationController pushViewController:listViewController animated:YES];
    }
}

- (void)setupInputView {
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
    self.textView.placeholder = NSLocalizedStringFromSelf(@"Tips_Input_Message_Here");
    self.textView.chatTextViewDelegate = self;
    self.textView.delegate = self;

    [self.emotionBtn setImage:[UIImage imageNamed:@"Chat_Emotion_Icon"] forState:UIControlStateNormal];
    [self.emotionBtn setImage:[UIImage imageNamed:@"Chat_Keyboard_Icon"] forState:UIControlStateSelected];
    self.emotionBtn.adjustsImageWhenHighlighted = NO;
    self.emotionBtn.selectedChangeDelegate = self;

    if (IS_IPHONE_X) {
        self.inputMessageViewBottom.constant = self.inputMessageViewBottom.constant - 35;
    }
}

- (MJRefreshNormalHeader *)refresHeader {
    // TODO:上拉刷新
    if (_refresHeader == nil) {
        WeakObject(self, weakSelf);
        _refresHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

            [weakSelf.tableView.mj_header endRefreshing];

            if (ISHAVEANCHORID) {
                [weakSelf getMorePrivateMsgWithUserId:weakSelf.anchorId];
            }
        }];
        _refresHeader.arrowView.hidden = YES;
        _refresHeader.lastUpdatedTimeLabel.hidden = YES;
        _refresHeader.stateLabel.hidden = YES;
    }
    return _refresHeader;
}

#pragma mark - 点击进入女士详情
- (void)showLadyDetail {
}

#pragma mark - IM消息
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"LSChatViewController::onLogin( [IM登录], errType : %d, errmsg : %@ )", errType, errmsg);
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errType == LCC_ERR_SUCCESS) {
            [weakSelf refreshPrivateMsgWithUserId:self.anchorId];
        }
    });
}

#pragma mark - 发送消息
- (void)sendMsg {
    // 回车/换行替换成空格
    NSString *string = [self.sendMessageManager deleteStringLineEnter:self.textView.text];
    // 删除所有空格
    NSString *str = [self.sendMessageManager deleteStringALLSpace:string];
    if (str.length > 0) {
        // 删除头尾空格
        NSString *sendStr = [self.sendMessageManager deleteStringHeadTailSpace:string];
        [[LiveModule module].analyticsManager reportActionEvent:SendPrivateMessage eventCategory:EventCategorySendMessage];
        if (ISHAVEANCHORID) {
            // 发送文本消息
            [self.messageManager sendPrivateMessage:self.anchorId message:sendStr];
        }
    }
    // 清空输入框
    [self.textView cleanText];
}

#pragma mark - 获取消息
- (void)getLocalMessage:(GetLocalMessage)finish {
    if (ISHAVEANCHORID) {
        // 设置已读
        [self.messageManager setPrivateMsgReaded:self.anchorId];
        WeakObject(self, weakSelf);
        [self.msgArray removeAllObjects];
        [self.messageManager getLocalPrivateMsgWithUserId:self.anchorId
                                            finishHandler:^(NSArray<LMMessageItemObject *> *_Nullable list) {
                                                if (list.count > 0) {
                                                    // 同步方法更新消息数组
                                                    [weakSelf forMessageItemAddMsaArray:list];
                                                    [weakSelf.tableView reloadData];
                                                    // 回调主线程刷新界面
                                                    [weakSelf scrollToEnd:NO];
                                                }
                                                finish();
                                            }];
    }
}

- (void)refreshPrivateMsgWithUserId:(NSString *)userId {
    // TODO:服务器获取私密消息列表
    WeakObject(self, weakSelf);
    [self.messageManager refreshPrivateMsgWithUserId:userId
                                       finishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, NSArray<LMMessageItemObject *> *_Nonnull list) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (success) {
                                                   [weakSelf.messageManager setPrivateMsgReaded:self.anchorId];
                                                   if (list.count > 0) {
                                                       [weakSelf forMessageItemAddMsaArray:list];
                                                       [weakSelf.tableView reloadData];
                                                       [weakSelf scrollToEnd:NO];
                                                   }
                                               }
                                           });
                                       }];
}

- (void)getMorePrivateMsgWithUserId:(NSString *)userId {
    // TODO:获取更多私密消息 (上拉刷新调用)
    [self.messageManager getMorePrivateMsgWithUserId:userId];
}

- (void)forMessageItemAddMsaArray:(NSArray<LMMessageItemObject *> *)list {
    for (LMMessageItemObject *item in list) {
        LSMessage *message = [[LSMessage alloc] init];
        message.sendMsgId = item.sendMsgId;
        message.createTime = item.createTime;
        message.sendType = item.sendType;
        message.statusType = item.statusType;
        message.sendErr = item.sendErr;
        message.msgType = item.msgType;
        message.userItem = item.userItem;
        message.privateItem = item.privateItem;
        message.systemItem = item.systemItem;
        message.warningItem = item.warningItem;
        message.timeMsgItem = item.timeMsgItem;

        if (message.privateItem.message.length > 0) {
            message.text = message.privateItem.message;
            message.attText = [[NSAttributedString alloc] initWithString:message.privateItem.message];
        }
        if (message.systemItem.message.length > 0) {
            message.text = message.systemItem.message;
            message.attText = [[NSAttributedString alloc] initWithString:message.systemItem.message];
        }
        [self.msgArray addObject:message];
    }
    self.tableView.msgArray = self.msgArray;
}

#pragma mark - 重新加载消息到界面
- (void)reloadData:(BOOL)isReloadView scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
    // 数据填充
    if (isReloadView) {

        [self.tableView reloadData];

        if (scrollToEnd) {
            [self scrollToEnd:animated];
        }
    }
}

- (void)scrollToEnd:(BOOL)animated {
    // TODO: 消息列表滚动到最底
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSInteger count = [self.tableView numberOfRowsInSection:0];
        if (count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    });
}

#pragma mark - LSChatTableViewDelegate
- (void)chatTextSelfRetryMessage:(LSChatSelfMessageCell *)cell sendErr:(NSInteger)sendErr {
    // 点击叹号弹出提示框
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    NSString *message;
    if (sendErr != LCC_ERR_SUCCESS) {
        if (sendErr == LCC_ERR_CONNECTFAIL) {
            message = NSLocalizedStringFromSelf(@"Send_Message_Trouble");
        } else {
            message = NSLocalizedStringFromSelf(@"Message_Not_Send");
        }
    }
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *otherAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", @"Retry") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clickButtonWithAlertVC:path.row];
    }];
    [alertVC addAction:cancelAC];
    [alertVC addAction:otherAC];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)clickButtonWithAlertVC:(NSInteger)tag {
    // TODO:消息重发
    LSMessage *message = self.msgArray[tag];
    if (ISHAVEANCHORID) {
        // 重发消息
        [self.messageManager repeatSendPrivateMsg:self.anchorId sendMsgId:message.sendMsgId];
    }
}

- (void)pushToAddCreditVC {
    //TODO: 跳转充值买点
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

#pragma mark - LMMessageManagerDelegate
- (void)onSendPrivateMessage:(BOOL)success errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg item:(LMMessageItemObject *_Nonnull)item {
    NSLog(@"LSChatViewController::([发送和重发的私信消息的成功或失败 success : %@, errType : %d, errmsg : %@ msgId : %d ])", success ? @"成功" : @"失败", errType, errmsg, item.msgId);
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{

        // 循环找到对应消息队列 更新消息状态
        for (NSInteger i = weakSelf.msgArray.count - 1; i >= 0; i--) {
            LSMessage *message = weakSelf.msgArray[i];
            if (message.sendMsgId == item.sendMsgId) {
                message.sendErr = item.sendErr;
                message.statusType = item.statusType;
                break;
            }
        }
        [weakSelf.tableView reloadData];
        // 回调主线程刷新界面
        [weakSelf scrollToEnd:NO];
    });
}

- (void)onRepeatSendPrivateMsgNotice:(NSString *_Nonnull)userId msgList:(NSArray<LMMessageItemObject *> *_Nonnull)msgList {
    NSLog(@"LSChatViewController::onRepeatSendPrivateMsgNotice([重发回调所有本地私信消息] msgList:%lu)", (unsigned long)[msgList count]);
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 刷新本地消息
        [weakSelf getLocalMessage:^{
        }];
    });
}

- (void)onUpdatePrivateMsgWithUserId:(NSString *)userId msgList:(NSArray<LMMessageItemObject *> *)msgList {
    NSLog(@"LSChatViewController::([私信更新消息（放在私信消息队列后面）count : %lu])", (unsigned long)msgList.count);
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (msgList.count > 0) {
            // 设置已读
            [weakSelf.messageManager setPrivateMsgReaded:self.anchorId];
            // 刷新本地消息
            [weakSelf forMessageItemAddMsaArray:msgList];
            [weakSelf reloadData:YES scrollToEnd:YES animated:NO];
        }
    });
}

- (void)onGetMorePrivateMsgWithUserId:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg userId:(NSString *)userId list:(NSArray<LMMessageItemObject *> *)list reqId:(int)reqId {
    NSLog(@"LSChatViewController::onGetMorePrivateMsgWithUserId([获取私信更多消息 success:%d errType:%d errMsg:%@ Contact:%lu])", success, errType, errmsg, (unsigned long)[list count]);
    WeakObject(self, weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 停止下拉loading
        [weakSelf.tableView.mj_header endRefreshing];
        // 获取是否可以上拉
        weakSelf.isCanGetMore = [weakSelf.messageManager isHasMorePrivateMsgWithUserId:self.anchorId];
        [weakSelf setTheTableViewMJHeadr:weakSelf.isCanGetMore];

        if (success) {
            if (list.count > 0) {
                for (NSInteger i = list.count - 1; i >= 0; i--) {
                    LMMessageItemObject *item = list[i];
                    LSMessage *message = [[LSMessage alloc] init];
                    message.sendMsgId = item.sendMsgId;
                    message.createTime = item.createTime;
                    message.sendType = item.sendType;
                    message.statusType = item.statusType;
                    message.msgType = item.msgType;
                    message.userItem = item.userItem;
                    message.privateItem = item.privateItem;
                    message.systemItem = item.systemItem;
                    message.warningItem = item.warningItem;
                    message.timeMsgItem = item.timeMsgItem;

                    if (message.privateItem.message.length > 0) {
                        message.text = message.privateItem.message;
                        message.attText = [[NSAttributedString alloc] initWithString:message.privateItem.message];
                    }
                    if (message.systemItem.message.length > 0) {
                        message.text = message.systemItem.message;
                        message.attText = [[NSAttributedString alloc] initWithString:message.systemItem.message];
                    }
                    [weakSelf.msgArray insertObject:message atIndex:0];
                }
                weakSelf.tableView.msgArray = weakSelf.msgArray;
                [weakSelf.tableView reloadData];

                if (list.count - 1 > 0) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:list.count - 1 inSection:0];
                    [weakSelf.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }
        }
    });
}

#pragma mark - 输入控件管理
- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllInputView)];
        [self.tableView addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
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

#pragma mark - 表情逻辑

- (void)selectedChanged:(id)sender {
    [self.textView endEditing:YES];
    UIButton *emotionBtn = (UIButton *)sender;
    if (emotionBtn.selected == YES) {
        // 弹出底部emotion的键盘
        [self showEmotionView];
    } else {
        // 切换成系统的的键盘
        [self showKeyboardView];
    }
}

- (void)setupEmotionInputView {

    self.emotionVC = [[LSChatEmotionViewController alloc] initWithNibName:nil bundle:nil];
    self.emotionVC.emotionDelegate = self;
    self.emotionVC.view.hidden = YES;
    [self.view addSubview:self.emotionVC.view];
    [self.emotionVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.inputMessageView.mas_width);
        make.height.equalTo(@219);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.top.equalTo(self.inputMessageView.mas_bottom).offset(5);
    }];
}

//显示表情选择
- (void)showEmotionView {
    // 增加手势
    [self addSingleTap];

    // 关闭系统键盘
    [self.textView resignFirstResponder];

    if (self.inputMessageViewBottom.constant != -self.emotionVC.view.frame.size.height) {
        self.emotionVC.view.hidden = NO;

        if (IS_IPHONE_X) {
            CGFloat height = self.emotionVC.view.frame.size.height + 35;
            [self moveInputBarWithKeyboardHeight:height withDuration:0.25];
        } else {
            // 未显示则显示
            [self moveInputBarWithKeyboardHeight:self.emotionVC.view.frame.size.height withDuration:0.25];
        }

        [self.emotionVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputMessageView.mas_bottom);
        }];
    }
    [self.emotionVC keyboardViewReload];
}

#pragma mark - 表情选择回调 LSChatEmotionViewControllerDelegate
- (void)didStandardEmotionViewItem:(NSInteger)index {
    if (self.textView.text.length < MAXInputCount) {
        //TODO: 插入表情到TextView
        LSChatEmotion *emotion = [self.emotionManager.stanEmotionList objectAtIndex:index];
        if (emotion.image) {
            [self.textView insertEmotion:emotion];
        }
    }
}

- (void)emotionKeyboardViewClickSend {
    //TODO: 表情列表发送逻辑
    [self sendMsg];
}

#pragma mark - 关闭所有输入控件
- (void)closeAllInputView {
    // 降低加速度
    self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal;

    // 移除手势
    [self removeSingleTap];

    // 关闭表情输入
    if (self.emotionBtn.selected == YES) {
        self.emotionBtn.selected = NO;
        [self moveInputBarWithKeyboardHeight:0 withDuration:0.25];
    }

    // 关闭系统键盘
    [self.textView resignFirstResponder];
}

#pragma mark - 消息列表文本解析
/**
 *  解析没钱警告消息
 *
 *  @param text 没钱警告消息
 *  @param linkMessage 可以点击的文字
 *  @param font        字体
 *  @return 没钱富文本警告消息
 */
- (NSAttributedString *)parseNoMomenyWarningMessage:(NSString *)text linkMessage:(NSString *)linkMessage font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : textColor
    }
                             range:NSMakeRange(0, attributeString.length)];

    LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
    attachment.text = linkMessage;
    attachment.url = [NSURL URLWithString:ADD_CREDIT_URL];
    attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
    NSMutableAttributedString *attributeLinkString = [[NSMutableAttributedString alloc] initWithString:linkMessage];
    [attributeLinkString addAttributes:@{
        NSFontAttributeName : font,
        NSAttachmentAttributeName : attachment,
    }
                                 range:NSMakeRange(0, attributeLinkString.length)];

    [attributeString appendAttributedString:attributeLinkString];
    return attributeString;
}
#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    BOOL bFlag = NO;
    //    [self.view layoutIfNeeded];

    if (height != 0) {
        // 弹出键盘

        // 增加加速度
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;

        self.inputMessageViewBottom.constant = -height;
        bFlag = YES;
        [self scrollToEnd:YES];

    } else {
        // 收起键盘
        if (IS_IPHONE_X) {
            self.inputMessageViewBottom.constant = -35;
        } else {
            self.inputMessageViewBottom.constant = 0;
        }
        self.emotionVC.view.hidden = YES;
    }

    //    [UIView animateWithDuration:duration animations:^{
    //        [self.view layoutIfNeeded];
    //    } completion:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];

    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // 从表情键盘切换成系统键盘,保存普通表情的富文本属性
    self.emotionAttributedString = self.textView.attributedText;
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];

    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    if (self.emotionBtn.selected == NO) {
        // 没有选择表情
        [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    }
}

#pragma mark - 输入回调
- (void)textViewDidChange:(UITextView *)textView {
    // 超过字符限制
    NSString *toBeString = textView.text;
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (position) {
        if (toBeString.length > MAXInputCount) {
            // 取出之前保存的属性
            textView.attributedText = self.emotionAttributedString;

        } else {
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
    // 检查是否系统表情
    if ([text containEmoji]) {
        result = NO;
    }

    // 判断输入的字是否是回车，即按下send
    if ([text isEqualToString:@"\n"]) {
        // 触发发送
        [self sendMsg];
        result = NO;
    } else {
        // 判断是否超过字符限制
        NSInteger strLength = textView.text.length - range.length + text.length;
        if (strLength > MAXInputCount && text.length >= range.length) {
            // 判断是否删除字符
            if ('\000' != [text UTF8String][0] && ![text isEqualToString:@"\b"]) {
                // 非删除字符，不允许输入
                result = NO;
            }
        }
    }
    // 允许输入
    return result;
}

#pragma mark - 输入栏高度改变回调
- (void)textViewChangeHeight:(LSChatTextView *)textView height:(CGFloat)height {
    if (height < INPUTMESSAGEVIEW_MAX_HEIGHT) {
        if (height + 10 < INPUTMESSAGEVIEW_NORMAL_HEIGHT) {
            self.inputMessageViewHeight.constant = INPUTMESSAGEVIEW_NORMAL_HEIGHT;
        } else {
            self.inputMessageViewHeight.constant = height + 10;
        }
    } else {
        self.inputMessageViewHeight.constant = INPUTMESSAGEVIEW_MAX_HEIGHT;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView setNeedsDisplay];
    });
    [self scrollToEnd:NO];
}

- (UIButton *)setupChooserBarBtnType:(int)type normalImage:(UIImage *)normalImage selectImage:(UIImage *)selectImage bgNormalImage:(UIImage *)bgNormalImage bgSelectImage:(UIImage *)bgSelectImage titleText:(NSString *)titleText titleNormalColor:(UIColor *)normalColor titleSelectColor:(UIColor *)selectColor {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (type) {
        [button setImage:normalImage forState:UIControlStateNormal];
        [button setImage:selectImage forState:UIControlStateSelected];
        [button setImage:selectImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    [button setBackgroundImage:bgNormalImage forState:UIControlStateNormal];
    [button setBackgroundImage:bgSelectImage forState:UIControlStateSelected];
    [button setBackgroundImage:bgSelectImage forState:UIControlStateSelected | UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setTitleColor:selectColor forState:UIControlStateSelected];
    [button setTitleColor:selectColor forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setTitle:titleText forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;
    
    return button;
}
@end
