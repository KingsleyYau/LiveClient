//
//  LSChatViewController.m
//  livestream
//
//  Created by Calvin on 2018/6/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSChatViewController.h"
#import "LSChatTitleView.h"
#import "LSChatTableView.h"
#import "LSChatTextView.h"
#import "LSMessage.h"
#import "LSChatTextAttachment.h"
#import "LSChatEmotion.h"
#import "LSChatEmotionKeyboardView.h"
#import "LSLiveStandardEmotionView.h"
#import "MJRefresh.h"
#define INPUTMESSAGEVIEW_MAX_HEIGHT 80
#define MAXInputCount 240
#define ADD_CREDIT_URL @"ADD_CREDIT_URL"
@interface LSChatViewController ()<LSChatTableViewDelegate,LSChatTextViewDelegate,LSChatTextViewDelegate,LSCheckButtonDelegate,LSChatEmotionKeyboardViewDelegate,LSLiveStandardEmotionViewDelegate>

// 头部导航栏
@property (nonatomic, strong) LSChatTitleView * titleView;

@property (weak, nonatomic) IBOutlet LSChatTableView *tableView;
@property (nonatomic, strong) MJRefreshNormalHeader *refresHeader;
// 发送栏
@property (weak, nonatomic) IBOutlet UIView *inputMessageView;
// 输入框
@property (weak, nonatomic) IBOutlet LSChatTextView *textView;
// 表情按钮
@property (weak, nonatomic) IBOutlet LSCheckButton *emotionBtn;
// 输入框高度约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inputMessageViewHeight;
// 输入框底部约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* inputMessageViewBottom;
// 文字的富文本属性
@property (nonatomic,copy) NSAttributedString *emotionAttributedString;
// 单击收起输入控件手势
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
// 消息数组
@property (nonatomic, strong) NSMutableArray * msgArray;
// 表情列表
@property (nonatomic, retain) NSArray *emotionArray;
// 表情列表(用于查找)
@property (nonatomic, retain) NSDictionary *emotionDict;
/** 表情选择器键盘 **/
@property (nonatomic, strong) LSChatEmotionKeyboardView *chatEmotionKeyboardView;
/** 普通表情 */
@property (nonatomic, strong) LSLiveStandardEmotionView *chatNomalEmotionView;
// 表情管理类
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;
@end

@implementation LSChatViewController

- (void)dealloc {
    self.tableView.mj_header = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableViewDelegate = self;
    [self.tableView setMj_header:self.refresHeader];
    
    self.msgArray = [NSMutableArray array];
    self.emotionArray = [NSMutableArray array];
    self.emotionDict = [NSDictionary dictionary];
    
    // 初始化表情管理器
    self.emotionManager = [LSChatEmotionManager emotionManager];

    [self setupInputView];
    [self setupEmotionInputView];

    [self getMessage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
 
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    // 标题
    self.titleView = [[LSChatTitleView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    self.titleView.personName.text = @"TestName";
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLadyDetail)];
    [self.titleView addGestureRecognizer:singleTap];
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 11.0) {
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
        }];
    }
    
    self.navigationItem.titleView = self.titleView;
}

- (void)setupInputView {
    self.textView.placeholder = NSLocalizedStringFromSelf(@"Tips_Input_Message_Here");
    self.textView.chatTextViewDelegate = self;
    
    [self.emotionBtn setImage:[UIImage imageNamed:@"Live_Emotion_Nomal"] forState:UIControlStateNormal];
    [self.emotionBtn setImage:[UIImage imageNamed:@"Live_Chat_Keyboard"] forState:UIControlStateSelected];
    self.emotionBtn.adjustsImageWhenHighlighted = NO;
    self.emotionBtn.selectedChangeDelegate = self;
}

- (MJRefreshNormalHeader *)refresHeader
{
    if (_refresHeader == nil) {
        WeakObject(self,weakSelf);
        _refresHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
 
                [weakSelf.tableView.mj_header endRefreshing];
            
            for (int i = 0; i < 10; i++) {
                LSMessage * message = [[LSMessage alloc]init];
                message.text = @"Calvin test222";
                message.attText = [[NSAttributedString alloc]initWithString:@"Calvin test222"];
                message.msgId = 1;
                message.status = MessageStatusFinish;
                message.type = MessageTypeText;
                message.sender =i%2==0?MessageSenderLady:MessageSenderSelf;
                [self.msgArray insertObject:message atIndex:0];
            }
 
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
 
        }];
        _refresHeader.arrowView.hidden = YES;
        _refresHeader.lastUpdatedTimeLabel.hidden = YES;
        _refresHeader.stateLabel.hidden = YES;
    }
    return _refresHeader;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击进入女士详情
- (void)showLadyDetail {
    
}

#pragma mark - 发送消息
- (void)sendMsg {
    
    self.textView.text = @"";
    
    LSMessage * message = [[LSMessage alloc]init];
    message.text = self.textView.text;
    message.attText = [[NSAttributedString alloc]initWithString:self.textView.text];
    message.msgId = 1;
    message.status = MessageStatusFinish;
    message.type = MessageTypeText;
    message.sender = MessageSenderSelf;
    [self.msgArray addObject:message];
    
    [self reloadData:YES scrollToEnd:YES animated:YES];
}

#pragma mark - 获取消息
- (void)getMessage {
    [self.msgArray removeAllObjects];
    
    for (int i = 0; i < 20; i++) {
        LSMessage * message = [[LSMessage alloc]init];
        message.text = @"Calvin test";
        message.attText = [[NSAttributedString alloc]initWithString:@"Calvin test"];
        message.msgId = 1;
        message.status = MessageStatusFinish;
        message.type = MessageTypeText;
        message.sender =i%2==0?MessageSenderLady:MessageSenderSelf;
        [self.msgArray addObject:message];
    }
    
    self.tableView.msgArray = self.msgArray;
    [self.tableView reloadData];
    [self scrollToEnd:NO];
   
}
#pragma mark - 重新加载消息到界面
- (void)reloadData:(BOOL)isReloadView scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
    // 数据填充
    

    if(isReloadView) {
        
        [self.tableView reloadData];
        
        if( scrollToEnd ) {
            [self scrollToEnd:animated];
        }
    }
}

// 消息列表滚动到最底
- (void)scrollToEnd:(BOOL)animated {
    NSInteger count = [self.tableView numberOfRowsInSection:0];
    if( count > 0 ) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:count -1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}




#pragma mark - 列表界面回调 (UITableViewDelegate)


#pragma mark - 点击消息提示按钮
- (void)chatTextSelfRetryButtonClick:(LSChatTextSelfTableViewCell *)cell {
    NSIndexPath * path = [self.tableView indexPathForCell:cell];
    [self handleErrorMsg:path.row];
}

- (void)handleErrorMsg:(NSInteger)index {
    
}
#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self closeAllInputView];
}

#pragma mark - 消息列表滚动到最底
- (void)scrollToEnd {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if( self.msgArray.count > 0 ) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.msgArray.count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

#pragma mark - 输入控件管理
- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllInputView)];
        [self.tableView addGestureRecognizer:self.singleTap];
    }
}

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

#pragma mark - 表情逻辑


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

- (void)setupEmotionInputView {
    // 普通表情
    if (self.chatNomalEmotionView == nil) {
        self.chatNomalEmotionView = [LSLiveStandardEmotionView emotionChooseView:self];
        self.chatNomalEmotionView.delegate = self;
        self.chatNomalEmotionView.stanListItem = self.emotionManager.stanListItem;
        self.chatNomalEmotionView.tipView.hidden = NO;
        self.chatNomalEmotionView.tipLabel.text = self.emotionManager.stanListItem.errMsg;
        [self.chatNomalEmotionView reloadData];
        self.chatNomalEmotionView.tipView.hidden = YES;
        self.chatNomalEmotionView.emotionCollectionView.backgroundColor = [UIColor whiteColor];
        self.chatNomalEmotionView.pageView.pageIndicatorTintColor = COLOR_WITH_16BAND_RGB(0xAAAAAA);
        self.chatNomalEmotionView.pageView.currentPageIndicatorTintColor = COLOR_WITH_16BAND_RGB(0x555555);
    }
    
    // 表情选择器
    if (self.chatEmotionKeyboardView == nil) {
        self.chatEmotionKeyboardView = [LSChatEmotionKeyboardView chatEmotionKeyboardView:self];
        self.chatEmotionKeyboardView.delegate = self;
        self.chatEmotionKeyboardView.buttonsView.backgroundColor = COLOR_WITH_16BAND_RGB(0xE7E8EE);
        self.chatEmotionKeyboardView.hidden = YES;
        [self.view addSubview:self.chatEmotionKeyboardView];
        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.inputMessageView.mas_width);
            make.height.equalTo(@219);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(5);
        }];
        
    }
}

//显示表情选择
- (void)showEmotionView {
    // 增加手势
    [self addSingleTap];
    
    // 关闭系统键盘
    [self.textView resignFirstResponder];
    
    if (self.inputMessageViewBottom.constant != -self.chatEmotionKeyboardView.frame.size.height) {
        self.chatEmotionKeyboardView.hidden = NO;
        
        if ([LSDevice iPhoneXStyle]) {
            CGFloat height = self.chatEmotionKeyboardView.frame.size.height + 35;
            [self moveInputBarWithKeyboardHeight:height withDuration:0.25];
        } else {
            // 未显示则显示
            [self moveInputBarWithKeyboardHeight:self.chatEmotionKeyboardView.frame.size.height withDuration:0.25];
        }
        
        [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputMessageView.mas_bottom);
        }];
    }
    [self.chatEmotionKeyboardView reloadData];
}

#pragma mark - 表情、礼物键盘选择回调 (LSPageChooseKeyboardViewDelegate)
- (NSUInteger)pagingViewCount:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView {
    return 1;
}

- (Class)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView classForIndex:(NSUInteger)index{
    Class cls = nil;
    
    if (index == 0) {
        // 普通表情
        cls = [LSLiveStandardEmotionView class];
    } else if (index == 1) {
        cls = [UIView class];
    }
    return cls;
}

- (UIView *)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView pageViewForIndex:(NSUInteger)index {
    UIView *view = nil;
    
    if (index == 0) {
        view = self.chatNomalEmotionView;
        view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);
    } else if (index == 1) {
    }
    return view;
}

- (void)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    if (index == 0) {
        // 普通表情
        [self.chatNomalEmotionView reloadData];
        
    } else if (index == 1) {
        // 高级表情
        
    }
}

- (void)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView didShowPageViewForDisplay:(NSUInteger)index {
    if (index == 0) {
    } else if (index == 1) {
    }
}

- (void)LSLiveStandardEmotionView:(LSLiveStandardEmotionView *)LSLiveStandardEmotionView didSelectNomalItem:(NSInteger)item {
    LSChatEmotion *emotion = [self.emotionManager.stanEmotionList objectAtIndex:item];
    [self.textView insertEmotion:emotion];
}

- (void)chatEmotionKeyboardViewSendEmotion {
    [self sendMsg];
}
#pragma mark - 关闭所有输入控件
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
    NSMutableAttributedString *attributeString = nil;
    if (text != nil) {
        attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    }
    NSRange range;
    NSRange endRange;
    NSRange valueRange;
    NSRange replaceRange;
    
    NSString* emotionOriginalString = nil;
    NSAttributedString* emotionAttString = nil;
    LSChatTextAttachment *attachment = nil;
    
    NSString* findString = attributeString.string;
    
    // 替换img
    while (
           (range = [findString rangeOfString:@"[img:"]).location != NSNotFound &&
           (endRange = [findString rangeOfString:@"]"]).location != NSNotFound &&
           range.location < endRange.location
           ) {
        // 增加表情文本
        attachment = [[LSChatTextAttachment alloc] init];
        attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
        
        // 解析表情字串
        valueRange = NSMakeRange(range.location, NSMaxRange(endRange) - range.location);
        // 原始字符串
        emotionOriginalString = [findString substringWithRange:valueRange];
        
        LSChatEmotion* emotion = [self.emotionDict objectForKey:emotionOriginalString];
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
    
    
    LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
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
#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    BOOL bFlag = NO;
    [self.view layoutIfNeeded];
    
    if(height != 0) {
        // 弹出键盘
        
        // 增加加速度
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        self.inputMessageViewBottom.constant = -height;
        bFlag = YES;
        [self scrollToEnd];
        
    } else {
        // 收起键盘
        self.inputMessageViewBottom.constant = 0;
    }
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // 从表情键盘切换成系统键盘,保存普通表情的富文本属性
    self.emotionAttributedString = self.textView.attributedText;
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    if( self.emotionBtn.selected == NO ) {
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
    // 检查是否系统表情
    if( [text containEmoji] ) {
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
        if (strLength >= MAXInputCount && text.length >= range.length) {
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
    if( height < INPUTMESSAGEVIEW_MAX_HEIGHT ) {
        self.inputMessageViewHeight.constant = height + 10;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView setNeedsDisplay];
    });
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
