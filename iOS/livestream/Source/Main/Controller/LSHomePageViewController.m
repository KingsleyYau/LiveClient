//
//  LSHomePageViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSHomePageViewController.h"

#import "FollowingViewController.h"
#import "HotViewController.h"

#import "LSUserInfoListViewController.h"
#import "LSUserUnreadCountManager.h"
#import "LSImManager.h"
@interface LSHomePageViewController () <JTSegmentControlDelegate, LSUserUnreadCountManagerDelegate, LSPZPagingScrollViewDelegate,IMLiveRoomManagerDelegate>


@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) JTSegmentControl *categoryControl;

/** 导航栏右边按钮 */
@property (nonatomic, strong) LSBadgeButton *navRightButton;

@property (nonatomic, strong) LSUserUnreadCountManager *unreadCountManager;

@property (nonatomic, assign) int unreadCount;

@property (nonatomic, strong) LSImManager *iMManager;
@end

@implementation LSHomePageViewController

- (void)dealloc
{
    [self.iMManager.client removeDelegate:self];
}

#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    //    self.title = @"Home";
    self.tabBarItem.image = [UIImage imageNamed:@"TabBarHome"];

    self.curIndex = 0;

    // 设置标题
    CGFloat width = [UIScreen mainScreen].bounds.size.width - (44 * 3);
    CGRect frame = CGRectMake(0, 0, width, 44);
    //    JTSegmentControl* categoryControl = [[JTSegmentControl alloc] initWithFrame:frame];
    JTSegmentControl *categoryControl = [[JTSegmentControl alloc] init];
    categoryControl.frame = frame;
    [categoryControl setupViewOpen];
    categoryControl.delegate = self;
    categoryControl.autoScrollWhenIndexChange = YES;
    categoryControl.items = [NSArray arrayWithObjects:@"Hot", @"Following", nil];
    categoryControl.font = [UIFont systemFontOfSize:16];
    categoryControl.selectedFont = [UIFont systemFontOfSize:16];
    categoryControl.itemBackgroundColor = [UIColor clearColor];
    categoryControl.itemSelectedBackgroundColor = [UIColor clearColor];
    categoryControl.itemTextColor = COLOR_WITH_16BAND_RGB(0xDB96FF);
    categoryControl.itemSelectedTextColor = COLOR_WITH_16BAND_RGB(0xFFF600);
    categoryControl.sliderViewColor = COLOR_WITH_16BAND_RGB(0xFFF600);

    self.categoryControl = categoryControl;
    self.navigationItem.titleView = categoryControl;

    UIBarButtonItem *barButtonItem = nil;
    UIImage *image = nil;

    // 右边按钮
    NSMutableArray *array = [NSMutableArray array];

    //    UIButton* navRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    image = [UIImage imageNamed:@"Home_Nav_Btn_Person"];
    //    [navRightButton setImage:image forState:UIControlStateNormal];
    //    [navRightButton sizeToFit];
    //    [navRightButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    //    [array addObject:barButtonItem];

    LSBadgeButton *navRightButton = [LSBadgeButton buttonWithType:UIButtonTypeCustom];
    self.navRightButton = navRightButton;
    image = [UIImage imageNamed:@"Home_Nav_Btn_Person"];
    [navRightButton setImage:image forState:UIControlStateNormal];
    [navRightButton sizeToFit];
    [navRightButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    [array addObject:barButtonItem];

    [self.navigationItem setRightBarButtonItems:array animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    HotViewController *hotVc = [[HotViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:hotVc];

    FollowingViewController *flVc = [[FollowingViewController alloc] initWithNibName:nil bundle:nil];
//    flVc.homePageVC = self;
    [self addChildViewController:flVc];

    //    DiscoverViewController* vc3 = [[DiscoverViewController alloc] initWithNibName:nil bundle:nil];
    //    [self addChildViewController:vc3];

    self.viewControllers = [NSArray arrayWithObjects:hotVc, flVc, nil];

    self.unreadCountManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadCountManager addDelegate:self];
    self.unreadCount = 0;
    
    self.iMManager = [LSImManager manager];
    [self.iMManager.client addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 设置不被NavigationBar和TabBar遮挡
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self reloadUnreadCount];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        // 第一次进入, 界面已经出现
        [self reloadData:YES animated:NO];
    }
    [super viewDidAppear:animated];
}

- (void)reloadUnreadCount
{
    self.unreadCount = 0;
    [self.unreadCountManager getResevationsUnredCount];
}

#pragma mark 获取用户中心未读数
- (void)onGetResevationsUnredCount:(BookingUnreadUnhandleNumItemObject *)item {
    self.unreadCount = item.totalNoReadNum;
    [self.unreadCountManager getBackpackUnreadCount];
}

- (void)onGetBackpackUnreadCount:(GetBackPackUnreadNumItemObject *)item {
    
    if (self.unreadCount == 0 && item.total > 0) {
        //显示红点
        self.navRightButton.badgeValue = nil;
        self.navRightButton.unreadCount = [NSString stringWithFormat:@"%d",item.total];
    }
    else
    {
      [self reloadUnreadMessage];
    }
}

#pragma mark - 界面事件
- (IBAction)searchAction:(id)sender {
    //    ChatListViewController *listViewController = [[ChatListViewController alloc]init];
    //    [self.navigationController pushViewController:listViewController animated:YES];

    LSUserInfoListViewController *vc = [[LSUserInfoListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView animated:(BOOL)animated {
    if (isReloadView) {
        if (animated) {
            self.navigationController.navigationBar.userInteractionEnabled = NO;
        }

        [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:animated];

        [self setupNavigationBar];
    }
}

/**
 *  刷新未读消息
 */
- (void)reloadUnreadMessage {
    self.navRightButton.unreadCount = nil;
    if (self.unreadCount == 0) {
        self.navRightButton.badgeValue = nil;
    } else {
        if (self.unreadCount > 99) {
             self.navRightButton.badgeValue = @"99+";
        }
        else
        {
              self.navRightButton.badgeValue = [NSString stringWithFormat:@"%d", self.unreadCount];
        }
    }
}

#pragma mark - 画廊回调 (LSPZPagingScrollViewDelegate)
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    return (nil == self.viewControllers) ? 0 : self.viewControllers.count;
}

- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)];
    
    return view;
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    if (vc.view != nil) {
        [vc.view removeFromSuperview];
    }

    [pageView removeAllSubviews];
    [pageView addSubview:vc.view];

    [vc.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pageView);
        make.left.equalTo(pageView);
        make.width.equalTo(pageView);
        make.height.equalTo(pageView);
    }];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.curIndex = index;
//    [self reportDidShowPage:index];
    [self.categoryControl moveTo:self.curIndex];
    [self setupNavigationBar];
}

#pragma mark - 分类选择器回调 (LSPZPagingScrollViewDelegate)
- (void)didSelectedWithSegement:(JTSegmentControl *_Nonnull)segement index:(NSInteger)index {
    self.curIndex = index;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
}

#pragma mark - 背包更新通知
- (void)onRecvBackpackUpdateNotice:(BackpackInfoObject *)item
{
    [self reloadUnreadCount];
}

#pragma mark - 预约更新通知
//接收主播预约私密邀请通知
- (void)onRecvScheduledInviteUserNotice:(NSString* _Nonnull)inviteId anchorId:(NSString* _Nonnull)anchorId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg msg:(NSString* _Nonnull)msg
{
    [self reloadUnreadCount];
}

//接收预约私密邀请回复通知
- (void)onRecvSendBookingReplyNotice:(ImBookingReplyObject* _Nonnull)item
{
    [self reloadUnreadCount];
}

//接收预约开始倒数通知
- (void)onRecvBookingNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg  leftSeconds:(int)leftSeconds
{
    [self reloadUnreadCount];
}

@end
