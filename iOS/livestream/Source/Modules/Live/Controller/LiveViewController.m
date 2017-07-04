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

#import "BigGiftAnimationView.h"
#import "LikeView.h"

#import "LiveRoomGiftItemObject.h"
#import "LiveGiftDownloadManager.h"
#import "UserHeadUrlManager.h"

#define INPUTMESSAGEVIEW_MAX_HEIGHT 44.0 * 2

#define LevelFontSize 14
#define LevelFont [UIFont systemFontOfSize:LevelFontSize]
#define LevelGrayColor [UIColor colorWithIntRGB:56 green:135 blue:213 alpha:255]

#define MessageFontSize 16
#define MessageFont [UIFont fontWithName:@"AvenirNext-DemiBold" size:MessageFontSize]

#define NameColor [UIColor colorWithIntRGB:255 green:210 blue:5 alpha:255]
#define MessageTextColor [UIColor whiteColor]

#define UnReadMsgCountFontSize 14
#define UnReadMsgCountColor NameColor
#define UnReadMsgCountFont [UIFont boldSystemFontOfSize:UnReadMsgCountFontSize]

#define UnReadMsgTipsFontSize 14
#define UnReadMsgTipsColor MessageTextColor
#define UnReadMsgTipsFont [UIFont boldSystemFontOfSize:UnReadMsgCountFontSize]

#define MessageCount 10

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

#pragma mark - 榜单管理器
@property (nonatomic, strong) TopFansViewController* topFansVC;

#pragma mark - 接口管理器
@property (nonatomic, strong) SessionRequestManager* sessionManager;

#pragma mark - 礼物管理器
@property (nonatomic, strong) GiftComboManager* giftComboManager;

#pragma mark - 礼物连击界面
@property (nonatomic, strong) NSMutableArray<GiftComboView*>* giftComboViews;
@property (nonatomic, strong) NSMutableArray<MASConstraint*>* giftComboViewsLeadings;

#pragma mark - 大礼物展现界面
@property (nonatomic, strong) BigGiftAnimationView *giftAnimationView;

#pragma mark - 礼物下载器
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;

#pragma mark - 用户头像管理器
@property (nonatomic, strong) UserHeadUrlManager *photoManager;

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
    NSLog(@"LiveViewController::initCustomParam()");
    
    [super initCustomParam];
    
    // 初始化消息
    self.msgArray = [NSMutableArray array];
    self.msgShowArray = [NSMutableArray array];
    self.needToReload = NO;
    
    // 初始请求管理器
    self.sessionManager = [SessionRequestManager manager];
    
    // 初始化IM管理器
    self.imManager = [IMManager manager];
    [self.imManager.client addDelegate:self];
    
    // 初始登录
    self.loginManager = [LoginManager manager];
    self.giftComboManager = [[GiftComboManager alloc] init];
    
    // 初始化礼物管理器
    self.giftDownloadManager = [LiveGiftDownloadManager giftDownloadManager];
    
    // 初始化头像管理器
    self.photoManager = [UserHeadUrlManager manager];
    
    // 注册大礼物结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationWhatIs:) name:@"animationIsAnimaing" object:nil];
}

- (void)dealloc {
    NSLog(@"LiveViewController::dealloc()");
    
    [self.imManager.client removeDelegate:self];
    
    // 去除大礼物结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"animationIsAnimaing" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 初始化视频界面
    self.videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.view.clipsToBounds = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 停止测试
    [self stopTest];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 开始测试
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
    self.imageViewHeaderLoader.view = self.imageViewHeader;
    self.imageViewHeaderLoader.url = @"http://images3.charmdate.com/woman_photo/C841/174/C162683-d.jpg";
    self.imageViewHeaderLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewHeaderLoader.url];
    [self.imageViewHeaderLoader loadImage];

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

#pragma mark - 点赞控件管理
- (void)showLike {
    NSInteger width = 36;
    LikeView* heart = [[LikeView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
    [self.view insertSubview:heart belowSubview:self.msgTableView];
    
    // 起始位置
    CGPoint fountainSource = CGPointMake(self.view.bounds.size.width - 20 - width/2.0, self.view.bounds.size.height - width /2.0 - 20);
    heart.center = fountainSource;
    
    // 随机生成图片
    int randomNum = arc4random_uniform(5);
    NSString *imageName = [NSString stringWithFormat:@"like_%d", randomNum];
    
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [heart setupImage:likeImageView];
    
    if ( randomNum != 4 ) {
        // 心心图片
        [heart setupShakeAnimation:likeImageView];
        [heart setupHeatBeatAnim:likeImageView];
    } else {
        // 特殊图片
    }
    
    // 显示
    [heart addSubview:likeImageView];
    [heart animateInView:self.view];
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

- (BOOL)showCombo:(GiftItem *)giftItem giftComboView:(GiftComboView *)giftComboView withUserHeadUrl:(NSString *)headUrl {
    BOOL bFlag = YES;
    
    giftComboView.hidden = NO;
    
    // 请求用户头像 连击头像
//    NSString *fromUrl = [self.photoManager getLiveRoomUserPhotoRequestWithUserId:giftItem.fromid andType:PHOTOTYPE_THUMB];
    [giftComboView.iconImageView sd_setImageWithURL:[NSURL URLWithString:headUrl]
                                   placeholderImage:[UIImage imageNamed:@""] options:0];
    
    // 名字标题
    giftComboView.nameLabel.text = giftItem.nickname;
    giftComboView.sendLabel.text = [NSString stringWithFormat:@"%ld",(long)giftItem.giftnum];
    
    // 数量
    giftComboView.beginNum = giftItem.multi_click_start;
    giftComboView.endNum = giftItem.multi_click_end;
    
    // 连击礼物
    NSString *imgUrl = [self.giftDownloadManager backImgUrlWithGiftID:giftItem.giftid];
    [giftComboView.giftImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]
                                   placeholderImage:[UIImage imageNamed:@""] options:0];
    
    giftComboView.item = giftItem;
    
    // 从左到右
    NSInteger index = giftComboView.tag;
    MASConstraint* giftComboViewsLeading = [self.giftComboViewsLeadings objectAtIndex:index];
    [giftComboViewsLeading uninstall];
    [giftComboView mas_updateConstraints:^(MASConstraintMaker *make) {
        MASConstraint* newGiftComboViewLeading = make.left.equalTo(self.giftView.mas_left).offset(10);
        [self.giftComboViewsLeadings replaceObjectAtIndex:index withObject:newGiftComboViewLeading];
    }];
    
    [giftComboView reset];
    [giftComboView start];
    
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
            giftComboView.endNum = giftItem.multi_click_end;
            break;
        }
    }
    
    if( giftComboView ) {
        // 有空闲的界面
        if( !giftComboView.playing ) {
            // 开始播放新的礼物连击
            NSString *fromUrl = [self.photoManager getLiveRoomUserPhotoRequestWithUserId:giftItem.fromid andType:PHOTOTYPE_THUMB];
            [self showCombo:giftItem giftComboView:giftComboView withUserHeadUrl:fromUrl];
            
            NSLog(@"LiveViewController::addCombo( Playing Gift : %@ )", giftItem);
        }

    } else {
        // 没有空闲的界面, 放到缓存
        [self.giftComboManager pushGift:giftItem];
        NSLog(@"LiveViewController::addCombo( Push Cache : %@ )", giftItem);
    }
}

- (void)starBigAnimationWithImageData:(NSData *)imageData {
    self.giftAnimationView = [BigGiftAnimationView sharedObject];
    self.giftAnimationView.userInteractionEnabled = NO;
    
    [self.view addSubview:self.giftAnimationView];
    
    [self.giftAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.giftAnimationView starAnimationWithImageData:imageData];
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
        NSString *fromUrl = [self.photoManager getLiveRoomUserPhotoRequestWithUserId:giftItem.fromid andType:PHOTOTYPE_THUMB];
        // 开始播放新的礼物连击
        [self showCombo:giftItem giftComboView:giftComboView withUserHeadUrl:fromUrl];
    }
}

#pragma mark - 通知大动画结束
- (void)animationWhatIs:(NSNotification *)notification{
    if (self.giftAnimationView) {
        [self.giftAnimationView removeFromSuperview];
        self.giftAnimationView = nil;
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
    cell.imageViewHeaderLoader.view = cell.imageViewHeader;
    cell.imageViewHeaderLoader.url = @"http://images3.charmdate.com/woman_photo/C841/174/C162683-d.jpg";
    cell.imageViewHeaderLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewHeaderLoader.url];
    [cell.imageViewHeaderLoader loadImage];
    
//    cell.imageViewHeaderLoader.sdWebImageView = cell.imageViewHeader;
//    [cell.imageViewHeaderLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
    
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
    [self.msgTableView registerClass:[MsgTableViewCell class] forCellReuseIdentifier:[MsgTableViewCell cellIdentifier]];
    
    self.msgTipsView.clipsToBounds = YES;
    self.msgTipsView.layer.cornerRadius = 6.0;
    self.msgTipsView.hidden = YES;
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMsgTipsView:)];
    [self.msgTipsView addGestureRecognizer:singleTap];
}

- (BOOL)sendMsg:(NSString *)text isLounder:(BOOL)isLounder {
    NSLog(@"LiveViewController::sendMsg( [发送文本消息], text : %@, isLounder : %d )", text, isLounder);
    
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
        }

        // 插入普通文本消息
        [self addChatMessage:text];
        
        if (isLounder) {
            // 调用IM命令(发送弹幕)
            [self.imManager.client sendRoomToast:self.roomId token:self.loginManager.loginItem.token nickName:self.loginManager.loginItem.nickName msg:text];
            
        } else {
            // 调用IM命令(发送直播间消息)
            [self.imManager.client sendRoomMsg:self.loginManager.loginItem.token roomId:self.roomId nickName:self.loginManager.loginItem.nickName msg:text];
            
        }
    }
    
    return bFlag;
}

- (void)addChatMessage:(NSString *)text {
    NSLog(@"LiveViewController::addChatMessage( [插入文本消息], nickName : %@ )", text);
    
    // 发送普通消息
    MsgItem* item = [[MsgItem alloc] init];
    item.level = self.loginManager.loginItem.level;
    item.name = self.loginManager.loginItem.nickName;
    item.text = text;
    
    NSMutableAttributedString *attributeString = [self sendItem:item textColor:MessageTextColor nameColor:NameColor andTextFont:MessageFont];
    item.attText = attributeString;
    
    // 插入到消息列表
    [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
}

// 插入点赞消息
- (void)addLikeMessage:(NSString *)nickName {
    NSLog(@"LiveViewController::addLikeMessage( [插入点赞消息], nickName : %@ )", nickName);
    
    MsgItem *item = [[MsgItem alloc] init];
    item.type = MsgType_ThumbUp;
    item.name = nickName;
    item.level = 0;
    
    NSMutableAttributedString *attributeString = [self sendItem:item textColor:COLOR_WITH_16BAND_RGB(0xb4a5ff) nameColor:NameColor andTextFont:MessageFont];
    item.attText = attributeString;
    
    [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
}

- (void)addMsg:(MsgItem *)item replace:(BOOL)replace scrollToEnd:(BOOL)scrollToEnd animated:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 计算当前显示的位置
        NSInteger lastVisibleRow = -1;
        if( self.msgTableView.indexPathsForVisibleRows.count > 0 ) {
            lastVisibleRow = [self.msgTableView.indexPathsForVisibleRows lastObject].row;
        }
        NSInteger lastRow = self.msgShowArray.count - 1;
        
        // 计算消息数量
        BOOL deleteOldMsg = NO;
        if( self.msgArray.count > 0 ) {
            if( replace ) {
                deleteOldMsg = YES;
                // 删除一条最新消息
                [self.msgArray removeObjectAtIndex:self.msgArray.count - 1];
                
            } else  {
                deleteOldMsg = (self.msgArray.count >= MessageCount);
                if( deleteOldMsg ) {
                    // 超出最大消息限制, 删除一条最旧消息
                    [self.msgArray removeObjectAtIndex:0];
                }
            }
        }
        
        // 增加新消息
        [self.msgArray addObject:item];

        if( lastVisibleRow >= lastRow ) {
            // 如果消息列表当前能显示最新的消息
            
            // 直接刷新
            [self.msgTableView beginUpdates];
            if( deleteOldMsg ) {
                if( replace ) {
                    // 删除一条最新消息
                    [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgShowArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    
                } else  {
                    // 超出最大消息限制, 删除列表一条旧消息
                    [self.msgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            
            // 替换显示的消息列表
            self.msgShowArray = [NSMutableArray arrayWithArray:self.msgArray];
            
            // 增加列表一条新消息
            [self.msgTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.msgShowArray.count - 1 inSection:0]] withRowAnimation:(deleteOldMsg && replace)?UITableViewRowAnimationNone:UITableViewRowAnimationBottom];
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
    
    NSMutableAttributedString *attStringMsg = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"UnRead_Messages")];
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

- (void)tapMsgTipsView:(id)sender {
    [self scrollToEnd:YES];
}

/**
 普通消息文本

 @param text 文字
 @param font 字体
 @param textColor 文字颜色
 @return 富文本
 */
- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    return attributeString;
}

- (NSAttributedString *)parseImageMessage:(UIImage *)image font:(UIFont *)font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];

    ChatTextAttachment *attachment = nil;
    
    // 增加表情文本
    attachment = [[ChatTextAttachment alloc] init];
//    attachment.bounds = CGRectMake(0, 0, font.lineHeight, font.lineHeight);
    attachment.image = image;
    
    // 生成表情富文本
    NSAttributedString* imageString = [NSAttributedString attributedStringWithAttachment:attachment];
    [attributeString appendAttributedString:imageString];
    
    return attributeString;
}

/**
 消息文本拼接
 
 @param item      消息item
 @param textcolor 聊天文本颜色
 @param nameColor 名字颜色
 @param font      字体大小
 @return 富文本
 */
- (NSMutableAttributedString *)sendItem:(MsgItem *)item textColor:(UIColor *)textcolor nameColor:(UIColor *)nameColor andTextFont:(UIFont *)font{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    switch (item.type) {
        case MsgType_Chat:{
            attributeString = [self appendAttributedStringWithFont:font nameColor:nameColor textColor:textcolor andMessage:[NSString stringWithFormat:@"%@ : ", item.name, nil] ParseMessage:[NSString stringWithFormat:@"%@ ",item.text] msgItem:item];
        }break;
        case MsgType_Join:{
            attributeString = [self appendAttributedStringWithFont:font nameColor:nameColor textColor:textcolor andMessage:item.name ParseMessage:NSLocalizedStringFromSelf(@"Member_Join") msgItem:item];
        }break;
        case MsgType_Gift:{
            attributeString = [self appendAttributedStringWithFont:font nameColor:nameColor textColor:textcolor andMessage:item.name ParseMessage:[NSString stringWithFormat:@"%@ %@ ",NSLocalizedStringFromSelf(@"Member_Gift"),item.giftId] msgItem:item];
        }break;
        case MsgType_Share:{
            attributeString = [self appendAttributedStringWithFont:font nameColor:nameColor textColor:textcolor andMessage:item.name ParseMessage:NSLocalizedStringFromSelf(@"Member_Share") msgItem:item];
        }break;
        case MsgType_Follow:{
            attributeString = [self appendAttributedStringWithFont:font nameColor:nameColor textColor:textcolor andMessage:item.name ParseMessage:NSLocalizedStringFromSelf(@"Member_Follow") msgItem:item];
        }break;
        case MsgType_ThumbUp:{
            attributeString = [self appendAttributedStringWithFont:font nameColor:nameColor textColor:textcolor andMessage:item.name ParseMessage:NSLocalizedStringFromSelf(@"Member_ThumbUp") msgItem:item];
        }break;
        default:
            break;
    }
    
    return attributeString;
}

- (NSMutableAttributedString *)appendAttributedStringWithFont:(UIFont *)font nameColor:(UIColor *)nameColor textColor:(UIColor *)textColor andMessage:(NSString *)message ParseMessage:(NSString *)parseMessage msgItem:(MsgItem *)item{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    
    if (item.type != MsgType_Join) {
        [attributeString appendAttributedString:[self parseMessage:[MsgTableViewCell textPreDetail] font:font color:nameColor]];
    }
    
    [attributeString appendAttributedString:[self parseMessage:message font:font color:nameColor]];
    
    if (item.type != MsgType_Chat) {
        
        parseMessage = [NSString stringWithFormat:@" %@",parseMessage];
    }
    
    [attributeString appendAttributedString:[self
                                                 parseMessage:parseMessage font:font color:textColor]];

    if (item.type == MsgType_Gift) {
        
        UIImageView *imageView = [[UIImageView alloc]init];
        [imageView sd_setImageWithURL:[NSURL URLWithString:item.smallImgUrl] placeholderImage:[UIImage imageNamed:@""] options:0];
        imageView.frame = CGRectMake(0, 0, 18, 18);
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [attributeString appendAttributedString:attachText];
        
    }
    
    return attributeString;
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
        
//        CGSize viewSize = CGSizeMake(self.msgTableView.frame.size.width,
//                                     [MsgTableViewCell cellHeight:self.msgTableView.frame.size.width detailString:item.attText]
//                                     );
//        height = viewSize.height;
        
        height = [tableView fd_heightForCellWithIdentifier:[MsgTableViewCell cellIdentifier] cacheByIndexPath:indexPath
                                    configuration:^(MsgTableViewCell *cell) {
                                        [cell updataChatMessage:item];
        }];

        
        
    }

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    // 数据填充
    if( indexPath.row < self.msgShowArray.count ) {
        MsgItem* item = [self.msgShowArray objectAtIndex:indexPath.row];
        
        MsgTableViewCell* msgCell = [tableView dequeueReusableCellWithIdentifier:[MsgTableViewCell cellIdentifier]];
        [msgCell updataChatMessage:item];
        cell = msgCell;

        switch (item.type) {
            case MsgType_Chat:
            case MsgType_ThumbUp:
            case MsgType_Follow:
            case MsgType_Gift:
            case MsgType_Share:{
                msgCell.lvView.hidden = NO;
            }break;
            case MsgType_Join:{
                msgCell.lvView.hidden = YES;
            }break;
            default:
                break;
        }

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
// 发送直播间消息回调
- (void)onSendRoomMsg:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{

    });
}

// 接收直播间文本消息通知回调
- (void)onRecvRoomMsg:(NSString* _Nonnull)roomId level:(int)level fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg {
    NSLog(@"LiveViewController::onRecvRoomMsg( [接收直播间文本消息回调], "
          "roomId : %@, level : %d, fromId : %@, nickName : %@, msg : %@ "
          ")",
          roomId, level, fromId, nickName, msg
          );
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [roomId isEqualToString:self.roomId] ) {
            // 插入聊天消息到列表
            MsgItem* item = [[MsgItem alloc] init];
            item.type = MsgType_Chat;
            item.level = level;
            item.name = nickName;
            item.text = msg;
            
            NSMutableAttributedString *attributeString = [self sendItem:item textColor:MessageTextColor nameColor:NameColor andTextFont:MessageFont];
            item.attText = attributeString;
            
            // 插入到消息列表
            [self addMsg:item replace:NO scrollToEnd:YES animated:YES];
        }
    });
}

- (void)onRecvFansRoomIn:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl {
    NSLog(@"LiveViewController::onRecvFansRoomIn( [接收观众进入房间回调], "
          "roomId : %@, userId : %@, nickName : %@, photoUrl : %@ "
          ")",
          roomId, userId, nickName, photoUrl
          );
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [roomId isEqualToString:self.roomId] ) {
            // 插入入场消息到列表
            MsgItem* item = [[MsgItem alloc] init];
            item.type = MsgType_Join;
            item.name = nickName;
            
            NSMutableAttributedString *attributeString = [self sendItem:item textColor:MessageTextColor nameColor:NameColor andTextFont:MessageFont];
            item.attText = attributeString;
            
            // (插入/替换)到到消息列表
            BOOL replace = NO;
            if( self.msgArray.count > 0 ) {
                MsgItem* lastItem = [self.msgArray lastObject];
                if( lastItem.type == item.type ) {
                    // 同样是入场消息, 替换最后一条
                    replace = YES;
                }
            }
            [self addMsg:item replace:replace scrollToEnd:YES animated:YES];
        }
    });
}

- (void)onRecvRoomGiftNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName giftId:(NSString *)giftId giftName:(NSString *)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id {
    NSLog(@"LiveViewController::onRecvRoomGiftNotice( [接收直播间礼物回调], "
          "roomId : %@, fromId : %@, nickName : %@, giftId : %@, giftName : %@, giftNum : %d "
          ")",
          roomId, fromId, nickName, giftId, giftName, giftNum);

    
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [roomId isEqualToString:self.roomId] ) {
            // 创建礼物
            GiftItem *giftItem = [GiftItem item:roomId fromID:fromId nickName:nickName giftID:giftId giftNum:giftNum multi_click:multi_click starNum:multi_click_start endNum:multi_click_end clickID:multi_click_id];
            
            MsgItem *msgItem = [[MsgItem alloc] init];
            msgItem.name = nickName;
            msgItem.level = 0;
            msgItem.type = MsgType_Gift;
            msgItem.giftId = giftId;
            msgItem.smallImgUrl = [self.giftDownloadManager backSmallImgUrlWithGiftID:giftItem.giftid];
            
            if ( multi_click ) {
                // 连击礼物
                [self addCombo:giftItem];
                
            } else {
                // 大礼物
                NSData *imageData = [self.giftDownloadManager doCheckLocalGiftWithGiftID:giftItem.giftid];
                [self starBigAnimationWithImageData:imageData];
            }
            
            // 增加文本消息
            NSMutableAttributedString *attributeString = [self sendItem:msgItem textColor:COLOR_WITH_16BAND_RGB(0x0cedf5) nameColor:NameColor andTextFont:MessageFont];
            msgItem.attText = attributeString;
                
            [self addMsg:msgItem replace:NO scrollToEnd:YES animated:YES];

        }
    });
}

- (void)onRecvPushRoomFav:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName isFirst:(BOOL)isFirst {
    NSLog(@"LiveViewController::onRecvPushRoomFav( [接收直播间点赞回调], roomId : %@, fromId : %@, nickName : %@, isFirst : %s )", roomId, fromId, nickName, isFirst?"true":"false");
    dispatch_async(dispatch_get_main_queue(), ^{
        // 显示点赞
        [self showLike];

        // 第一次接收, 插入文本消息
        if ( isFirst ) {
            [self addLikeMessage:nickName];
        }
    });
}

// 发送弹幕消息回调
- (void)onSendRoomToast:(BOOL)success reqId:(unsigned int)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg coins:(double)coins {
    NSLog(@"LiveViewController::onSendRoomToast( [发送弹幕消息回调], success : %s, reqId : %d, errType : %d, errMsg : %@, coins : %f )", success?"true":"false", reqId, errType, errMsg, coins);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            
        }
    });
}

// 接收弹幕消息通知回调
- (void)onRecvRoomToastNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName msg:(NSString *)msg {
    NSLog(@"LiveViewController::onRecvRoomToastNotice( [接收弹幕消息通知回调], roomId : %@, fromId : %@, nickName : %@, msg : %@ )", roomId, fromId, nickName, msg);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 插入普通文本消息
        [self addChatMessage:msg];
        
        // 插入到弹幕
        BarrageModel* item = [[BarrageModel alloc] init];
        item.name = nickName;
        item.message = msg;
        item.level = PriorityLevelHigh;
        
        NSArray* items = [NSArray arrayWithObjects:item, nil];
        [self.barrageView insertBarrages:items immediatelyShow:YES];

    });
}

#pragma mark - 测试
- (void)test {
    self.giftItemId = 1;
    self.msgId = 1;
    
//    self.testTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(testMethod) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.testTimer forMode:NSRunLoopCommonModes];
//    
//    self.testTimer2 = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(testMethod2) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.testTimer2 forMode:NSRunLoopCommonModes];
//    
//    self.testTimer3 = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(testMethod3) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.testTimer3 forMode:NSRunLoopCommonModes];
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
    item.fromid = self.loginManager.loginItem.userId;
    item.nickname = @"Max";
    item.giftid = [NSString stringWithFormat:@"%ld", (long)self.giftItemId++];
    item.multi_click_start = 0;
    item.multi_click_end = 10;
    
    [self addCombo:item];
}

- (void)testMethod2 {
    NSString* msg = [NSString stringWithFormat:@"msg%ld", (long)self.msgId++];
    [self sendMsg:msg isLounder:YES];
}

- (void)testMethod3 {
    NSString* msg = [NSString stringWithFormat:@"msg%ld", (long)self.msgId++];
    [self sendMsg:msg isLounder:NO];
}

@end
