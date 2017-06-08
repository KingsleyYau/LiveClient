//
//  LiveViewController.m
//  livestream
//
//  Created by Max on 2017/5/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveViewController.h"
#import "TopFansViewController.h"

#import "LiveStreamPublisher.h"
#import "LiveStreamPlayer.h"

#import "MsgTableViewCell.h"
#import "MsgItem.h"

#import "FileCacheManager.h"

#import "GetLiveRoomFansListRequest.h"

#define INPUTMESSAGEVIEW_MAX_HEIGHT 44.0 * 2

#define LevelFontSize 14
#define LevelFont [UIFont systemFontOfSize:LevelFontSize]
#define LevelGrayColor [UIColor colorWithIntRGB:56 green:135 blue:213 alpha:255]

#define MessageFontSize 18
#define MessageFont [UIFont boldSystemFontOfSize:MessageFontSize]

#define NameColor [UIColor colorWithIntRGB:255 green:210 blue:5 alpha:255]
#define MessageTextColor [UIColor whiteColor]

#define UnReadMsgCountFontSize 14
#define UnReadMsgCountColor NameColor
#define UnReadMsgCountFont [UIFont boldSystemFontOfSize:UnReadMsgCountFontSize]

#define UnReadMsgTipsFontSize 14
#define UnReadMsgTipsColor MessageTextColor
#define UnReadMsgTipsFont [UIFont boldSystemFontOfSize:UnReadMsgCountFontSize]

#define MessageCount 500

@interface LiveViewController () <UITextFieldDelegate, KKCheckButtonDelegate, BarrageViewDataSouce, BarrageViewDelegate, GiftComboViewDelegate, IMLiveRoomManagerDelegate>

#pragma mark - 消息列表

/**
 用于显示的消息列表
 @description 注意在主线程操作
 */
@property (strong) NSMutableArray<MsgItem*>* msgShowArray;

/**
 用于保存真实的消息列表
 @description 注意在主线程操作
 */
@property (strong) NSMutableArray<MsgItem*>* msgArray;

/**
 是否需要刷新消息列表
 @description 注意在主线程操作
 */
@property (assign) BOOL needToReload;

/**
 未读消息数量
 */
@property (assign) NSInteger unReadMsgCount;

#pragma mark - 榜单管理器
@property (nonatomic, strong) TopFansViewController* topFansVC;

#pragma mark - 接口管理器
@property (nonatomic, strong) SessionRequestManager* sessionManager;

#pragma mark - 礼物管理器
@property (nonatomic, strong) GiftComboManager* giftComboManager;

#pragma mark - 礼物连击界面
@property (nonatomic, strong) NSMutableArray<GiftComboView*>* giftComboViews;
@property (nonatomic, strong) NSMutableArray<MASConstraint*>* giftComboViewsLeadings;


#pragma mark - 测试
@property (nonatomic, weak) NSTimer* testTimer;
@property (nonatomic, assign) NSInteger giftItemId;
@property (nonatomic, weak) NSTimer* testTimer2;
@property (nonatomic, weak) NSTimer* testTimer3;
@property (nonatomic, assign) NSInteger msgId;

@end

@implementation LiveViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.msgArray = [NSMutableArray array];
    self.msgShowArray = [NSMutableArray array];
    self.needToReload = NO;
    
    self.sessionManager = [SessionRequestManager manager];
    self.imManager = [IMManager manager];
    [self.imManager.client addDelegate:self];
    
    self.loginManager = [LoginManager manager];
    self.giftComboManager = [[GiftComboManager alloc] init];
    
}

- (void)dealloc {
    [self.imManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.view.clipsToBounds = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self stopTest];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 测试
    [self test];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化主播信息控件
    [self setupRoomView];
    
    // 初始化榜单信息控件
    [self setupFansView];
    
    // 初始化连击控件
    [self setupGiftView];
    
    // 初始化弹幕
    [self setupBarrageView];
    
    // 初始化消息列表
    [self setupTableView];
}

#pragma mark - 主播信息管理
- (void)setupRoomView {
    
    self.roomView.layer.masksToBounds = YES;
    self.roomView.layer.cornerRadius = self.roomView.frame.size.height / 2;
    
    self.imageViewHeader.layer.masksToBounds = YES;
    self.imageViewHeader.layer.cornerRadius = self.imageViewHeader.frame.size.height / 2;
    
    self.imageViewHeaderLoader = [ImageViewLoader loader];
//    self.imageViewHeaderLoader.view = self.imageViewHeader;
    self.imageViewHeaderLoader.sdWebImageView = self.imageViewHeader;
    self.imageViewHeaderLoader.url = @"http://images3.charmdate.com/woman_photo/C841/174/C162683-d.jpg";
    [self.imageViewHeaderLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
//    self.imageViewHeaderLoader.url = self.liveInfo.photoUrl;
//    self.imageViewHeaderLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewHeaderLoader.url];
//    [self.imageViewHeaderLoader loadImage];
//    self.announNameLabel.text = self.liveInfo.nickName;
//    self.audienceNumLabel.text = [NSString stringWithFormat:@"%d",self.liveInfo.fansNum];
}

#pragma mark - 榜单信息管理
- (void)setupFansView {
    self.fansView.layer.masksToBounds = YES;
    self.fansView.layer.cornerRadius = self.fansView.frame.size.height / 2;
    
    self.topFansVC = [[TopFansViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.topFansVC];
    [self.view addSubview:self.topFansVC.view];
    [self.topFansVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(30);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-30);
    }];
    self.topFansVC.view.hidden = YES;
    
}

- (IBAction)fansAction:(id)sender {
    self.topFansVC.view.hidden = NO;
}

#pragma mark - 连击管理
- (void)setupGiftView {
    [self.giftView removeAllSubviews];
    
    self.giftComboViews = [NSMutableArray array];
    self.giftComboViewsLeadings = [NSMutableArray array];
    
    GiftComboView* preGiftComboView = nil;
    
    for(int i = 0; i < 2; i++) {
        GiftComboView* giftComboView = [GiftComboView giftComboView:self];
        [self.giftView addSubview:giftComboView];
        [self.giftComboViews addObject:giftComboView];
        
        giftComboView.tag = i;
        giftComboView.delegate = self;
        giftComboView.hidden = YES;
        
        NSNumber* height = [NSNumber numberWithInteger:giftComboView.frame.size.height];
        
        if( !preGiftComboView ) {
            [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.giftView);
                make.width.equalTo(@220);
                make.height.equalTo(height);
                MASConstraint* leading = make.left.equalTo(self.giftView.mas_left).offset(-220);
                [self.giftComboViewsLeadings addObject:leading];
            }];
            
        } else {
            [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(preGiftComboView.mas_top).offset(-5);
                make.width.equalTo(@220);
                make.height.equalTo(height);
                MASConstraint* leading = make.left.equalTo(self.giftView.mas_left).offset(-220);
                [self.giftComboViewsLeadings addObject:leading];
            }];
        }
        
        preGiftComboView = giftComboView;
    }
}

- (BOOL)showCombo:(GiftItem *)giftItem giftComboView:(GiftComboView *)giftComboView {
    BOOL bFlag = YES;
    
    giftComboView.hidden = NO;
    [giftComboView reset];
    
    // 连击头像
    giftComboView.imageViewHeaderLoader = [ImageViewLoader loader];
//    giftComboView.imageViewHeaderLoader.view = giftComboView.iconImageView;
    giftComboView.imageViewHeaderLoader.url = @"http://images3.charmdate.com/woman_photo/C841/174/C162683-d.jpg";
//    giftComboView.imageViewHeaderLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:giftComboView.imageViewHeaderLoader.url];
//    [giftComboView.imageViewHeaderLoader loadImage];
    giftComboView.imageViewHeaderLoader.sdWebImageView = giftComboView.iconImageView;
    [giftComboView.imageViewHeaderLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
    
    // 名字标题
    giftComboView.nameLabel.text = @"Max";
    giftComboView.sendLabel.text = giftItem.itemId;
    
    // 数量
    giftComboView.beginNum = giftItem.start;
    giftComboView.endNum = giftItem.end;
    
    // 连击礼物
    giftComboView.imageViewGiftLoader = [ImageViewLoader loader];
//    giftComboView.imageViewGiftLoader.view = giftComboView.giftImageView;
    giftComboView.imageViewGiftLoader.url = @"http://images3.charmdate.com/woman_photo/C841/174/C162683-d.jpg";
//    giftComboView.imageViewGiftLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:giftComboView.imageViewGiftLoader.url];
//    [giftComboView.imageViewGiftLoader loadImage];
    giftComboView.imageViewGiftLoader.sdWebImageView = giftComboView.giftImageView;
    [giftComboView.imageViewGiftLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
    
    // 从左到右
    NSInteger index = giftComboView.tag;
    MASConstraint* giftComboViewsLeading = [self.giftComboViewsLeadings objectAtIndex:index];
    [giftComboViewsLeading uninstall];
    [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
        MASConstraint* newGiftComboViewLeading = make.left.equalTo(self.giftView.mas_left).offset(10);
        [self.giftComboViewsLeadings replaceObjectAtIndex:index withObject:newGiftComboViewLeading];
    }];
    
    NSTimeInterval duration = 0.3;
    [UIView animateWithDuration:duration animations:^{
        [self.giftView layoutIfNeeded];
    
    } completion:^(BOOL finished) {
        // 开始连击
        [giftComboView playGiftCombo];
    }];
    
    return bFlag;
}

- (void)addCombo:(GiftItem *)giftItem {
    // 寻找可用界面
    GiftComboView* giftComboView = nil;
    
    for(GiftComboView* view in self.giftComboViews) {
        if( !view.playing ) {
            // 寻找空闲的界面
            giftComboView = view;
            
        } else if( [view.item.itemId isEqualToString:giftItem.itemId] ) {
            
            // 寻找正在播放同一个连击礼物的界面
            giftComboView = view;
            // 更新最后连击数字
            giftComboView.item.end = giftItem.end;
        
            break;
        }
    }
    
    if( giftComboView ) {
        // 有空闲的界面
        if( !giftComboView.playing ) {
            // 开始播放新的礼物连击
            [self showCombo:giftItem giftComboView:giftComboView];
        }
        
    } else {
        // 没有空闲的界面, 放到缓存
        [self.giftComboManager pushGift:giftItem];
    }
}

#pragma mark - 连击回调(GiftComboViewDelegate)
- (void)playComboFinish:(GiftComboView *)giftComboView {
    // 收回界面
    NSInteger index = giftComboView.tag;
    MASConstraint* giftComboViewsLeading = [self.giftComboViewsLeadings objectAtIndex:index];
    [giftComboViewsLeading uninstall];
    [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
        MASConstraint* newGiftComboViewLeading = make.left.equalTo(self.giftView.mas_left).offset(-220);
        [self.giftComboViewsLeadings replaceObjectAtIndex:index withObject:newGiftComboViewLeading];
    }];
    giftComboView.hidden = YES;
    [self.giftView layoutIfNeeded];
    
    // 显示下一个
    GiftItem* giftItem = [self.giftComboManager popGift:nil];
    if( giftItem ) {
        // 开始播放新的礼物连击
        [self showCombo:giftItem giftComboView:giftComboView];
    }
}

#pragma mark - 弹幕管理
- (void)setupBarrageView {
    self.barrageView.delegate = self;
    self.barrageView.dataSouce = self;
}

#pragma mark - 弹幕回调(BarrageView)
- (NSUInteger)numberOfRowsInTableView:(BarrageView *)barrageView {
    return 2;
}

- (BarrageViewCell *)barrageView:(BarrageView *)barrageView cellForModel:(id<BarrageModelAble>)model {
    BarrageModelCell *cell = [BarrageModelCell cellWithBarrageView:barrageView];
    BarrageModel *item = (BarrageModel *)model;
    
    cell.imageViewHeaderLoader = [ImageViewLoader loader];
    cell.imageViewHeaderLoader.sdWebImageView = cell.imageViewHeader;
    cell.imageViewHeaderLoader.url = @"http://images3.charmdate.com/woman_photo/C841/174/C162683-d.jpg";
//    cell.imageViewHeaderLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewHeaderLoader.url];
    [cell.imageViewHeaderLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
    
    cell.labelName.text = item.name;
    cell.labelMessage.text = item.message;
    
    return cell;
}

- (void)barrageView:(BarrageView *)barrageView didSelectedCell:(BarrageViewCell *)cell {

}

- (void)barrageView:(BarrageView *)barrageView willDisplayCell:(BarrageViewCell *)cell {

}

- (void)barrageView:(BarrageView *)barrageView didEndDisplayingCell:(BarrageViewCell *)cell {

}

#pragma mark - 消息列表管理
- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.msgTableView setTableFooterView:footerView];
    
    self.msgTableView.backgroundView = nil;
    self.msgTableView.backgroundColor = [UIColor clearColor];
    
    self.msgTipsView.clipsToBounds = YES;
    self.msgTipsView.layer.cornerRadius = 6.0;
    self.msgTipsView.hidden = YES;
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMsgTipsView:)];
    [self.msgTipsView addGestureRecognizer:singleTap];
}

- (BOOL)sendMsg:(NSString *)text isLounder:(BOOL)isLounder {
    BOOL bFlag = NO;
    
    if( text.length > 0 ) {
        bFlag = YES;
        
        if ( isLounder ) {
            // 发送弹幕
            BarrageModel* item = [[BarrageModel alloc] init];
            item.name = self.loginManager.loginItem.nickName;
            item.message = text;
            item.level = PriorityLevelHigh;
            
            // 插入到弹幕
            NSArray* items = [NSArray arrayWithObjects:item, nil];
            [self.barrageView insertBarrages:items immediatelyShow:YES];

        } else {
            // 发送普通消息
            MsgItem* item = [[MsgItem alloc] init];
            item.level = self.loginManager.loginItem.level;
            item.name = self.loginManager.loginItem.nickName;
            item.text = text;
            
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
            
            [attributeString appendAttributedString:[self parseMessage:[MsgTableViewCell textPreDetail] font:MessageFont color:NameColor]];
            [attributeString appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ : ", item.name, nil] font:MessageFont color:NameColor]];
            [attributeString appendAttributedString:[self parseMessage:item.text font:MessageFont color:MessageTextColor]];
            
            item.attText = attributeString;
            
            // 插入到消息列表
            [self addMsg:item scrollToEnd:YES animated:YES];
            
            // 调用IM命令
            [self.imManager.client sendRoomMsg:self.loginManager.loginItem.token roomId:self.roomId nickName:self.loginManager.loginItem.nickName msg:text];
        }
    }
    
    return bFlag;
}

- (void)addMsg:(MsgItem *)item scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 计算当前显示的位置
        NSInteger lastVisibleRow = -1;
        if( self.msgTableView.indexPathsForVisibleRows.count > 0 ) {
            lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
        }
        NSInteger lastRow = self.msgShowArray.count - 1;
        
        // 计算消息数量
        BOOL deleteOldMsg = self.msgArray.count >= MessageCount;
        if( deleteOldMsg ) {
            // 超出最大消息限制, 删除一条旧消息
            [self.msgArray removeObjectAtIndex:0];
        }
        
        // 增加新消息
        [self.msgArray addObject:item];
        
        if( lastVisibleRow >= lastRow ) {
            // 如果消息列表当前能显示最新的消息
            
            // 替换显示的消息列表
            self.msgShowArray = [NSMutableArray arrayWithArray:self.msgArray];
            
            // 直接刷新
            [self.msgTableView beginUpdates];
            if( deleteOldMsg ) {
                // 超出最大消息限制, 删除列表一条旧消息
                [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // 增加列表一条新消息
            [self.msgTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgShowArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.msgTableView endUpdates];
            
            // 拉到最底
            if( scrollToEnd ) {
                [self scrollToEnd:animated];
            }
            
        } else {
            // 标记为需要刷新数据
            self.needToReload = YES;
            
            // 显示提示信息
            [self showUnReadMsg];
        }
    });
}

- (void)scrollToEnd:(BOOL)animated {
    NSInteger count = [self.msgTableView numberOfRowsInSection:0];
    if( count > 0 ) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
        [self.msgTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)showUnReadMsg {
    self.unReadMsgCount++;
    self.msgTipsView.hidden = NO;
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld ", (long)self.unReadMsgCount]];
    [attString addAttributes:@{
                               NSFontAttributeName : UnReadMsgCountFont,
                               NSForegroundColorAttributeName:UnReadMsgCountColor
                               }
                       range:NSMakeRange(0, attString.length)
     ];
    
    NSMutableAttributedString *attStringMsg = [[NSMutableAttributedString alloc] initWithString:@"unread messages"];
    [attStringMsg addAttributes:@{
                                  NSFontAttributeName : UnReadMsgTipsFont,
                                  NSForegroundColorAttributeName:UnReadMsgTipsColor
                                  }
                          range:NSMakeRange(0, attStringMsg.length)
     ];
    
    [attString appendAttributedString:attStringMsg];
    
    self.msgTipsLabel.attributedText = attString;
}

- (void)hideUnReadMsg {
    self.unReadMsgCount = 0;
    self.msgTipsView.hidden = YES;
}

- (NSAttributedString* )parseMessage:(NSString* )text font:(UIFont* )font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    return attributeString;
}

- (void)tapMsgTipsView:(id)sender {
    [self scrollToEnd:YES];
}

#pragma mark - 消息列表列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = self.msgArray?self.msgArray.count:0;

    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    // 数据填充
    if( indexPath.row < self.msgShowArray.count ) {
        MsgItem* item = [self.msgShowArray objectAtIndex:indexPath.row];
        
        CGSize viewSize = CGSizeMake(self.msgTableView.frame.size.width,
                                     [MsgTableViewCell cellHeight:self.msgTableView.frame.size.width detailString:item.attText]
                                     );
        height = viewSize.height;
        
    }

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    // 数据填充
    if( indexPath.row < self.msgShowArray.count ) {
        MsgItem* item = [self.msgShowArray objectAtIndex:indexPath.row];
        
        MsgTableViewCell* msgCell = [MsgTableViewCell getUITableViewCell:tableView];
        msgCell.labelLevel.text = [NSString stringWithFormat:@"%lld", (long long)item.level, nil];
        msgCell.label.attributedText = item.attText;
        
        cell = msgCell;
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@""];
        if( !cell ) {
            cell = [[UITableViewCell alloc] init];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger lastVisibleRow = -1;
    if( self.msgTableView.indexPathsForVisibleRows.count > 0 ) {
        lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
    }
    NSInteger lastRow = self.msgShowArray.count - 1;
    
    if( self.msgShowArray.count > 0 && lastVisibleRow == lastRow ) {
        // 已经拖动到最底, 刷新界面
        if( self.needToReload ) {
            self.needToReload = NO;
            
            // 收起提示信息
            [self hideUnReadMsg];
            
            // 刷新消息列表
            self.msgShowArray = [NSMutableArray arrayWithArray:self.msgArray];
            [self.msgTableView reloadData];
            
            // 同步位置
            [self scrollToEnd:NO];
        }

    }
}

#pragma mark - 获取观众列表
- (void)getFansList {
    GetLiveRoomFansListRequest* request = [[GetLiveRoomFansListRequest alloc] init];
    request.roomId = self.roomId;
    
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<ViewerFansItemObject *> * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 刷新粉丝头像列表
        });
    };
    
    [self.sessionManager sendRequest:request];
}

#pragma mark - IM回调
- (void)onSendRoomMsg:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

- (void)onRecvRoomMsg:(NSString* _Nonnull)roomId level:(int)level fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [roomId isEqualToString:self.roomId] ) {
            // 插入消息到列表
            MsgItem* item = [[MsgItem alloc] init];
            item.level = level;
            item.name = nickName;
            item.text = msg;
            
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
            
            [attributeString appendAttributedString:[self parseMessage:[MsgTableViewCell textPreDetail] font:MessageFont color:NameColor]];
            [attributeString appendAttributedString:[self parseMessage:[NSString stringWithFormat:@"%@ : ", item.name, nil] font:MessageFont color:NameColor]];
            [attributeString appendAttributedString:[self parseMessage:item.text font:MessageFont color:MessageTextColor]];
            
            item.attText = attributeString;
            
            // 插入到消息列表
            [self addMsg:item scrollToEnd:YES animated:YES];
        }
    });
}

#pragma mark - 测试
- (void)test {
    self.giftItemId = 1;
    self.msgId = 1;
    
    self.testTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(testMethod) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.testTimer forMode:NSRunLoopCommonModes];
    
    self.testTimer2 = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(testMethod2) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.testTimer2 forMode:NSRunLoopCommonModes];
    
    self.testTimer3 = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(testMethod3) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.testTimer3 forMode:NSRunLoopCommonModes];
}

- (void)stopTest {
    [self.testTimer invalidate];
    self.testTimer = nil;
    
    [self.testTimer2 invalidate];
    self.testTimer2 = nil;
    
    [self.testTimer3 invalidate];
    self.testTimer3 = nil;
}

- (void)testMethod {
    GiftItem* item = [[GiftItem alloc] init];
    item.userId = self.loginManager.loginItem.userId;
    item.userName = @"Max";
    item.giftId = [NSString stringWithFormat:@"%ld", (long)self.giftItemId++];
    item.giftName = @"flower";
    item.start = 0;
    item.end = 100;
    
    [self addCombo:item];
}

- (void)testMethod2 {
    [self sendMsg:@"test" isLounder:YES];
}

- (void)testMethod3 {
    NSString* msg = [NSString stringWithFormat:@"msg%ld", (long)self.msgId++];
    [self sendMsg:msg isLounder:NO];
}

@end
