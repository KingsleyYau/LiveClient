//
//  LSLiveBroadcasterViewController.m
//  livestream_anchor
//
//  Created by test on 2018/2/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSLiveBroadcasterViewController.h"
#import "LSTodosViewController.h"
#import "LSUserUnreadCountManager.h"
#import "JDSegmentControl.h"
#import "ZBLSRequestManager.h"
#import "DialogTip.h"

@interface LSLiveBroadcasterViewController ()<LSUserUnreadCountManagerDelegate,JDSegmentControlDelegate,LSPZPagingScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *incomeCount;
@property (weak, nonatomic) IBOutlet UILabel *bookingCount;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet LSProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) LSBadgeButton *badge;
@property (nonatomic, assign) int unreadCount;
@property (weak, nonatomic) IBOutlet UIView *todosView;
@property (nonatomic, strong) LSUserUnreadCountManager *unreadCountManager;
@property (nonatomic, strong) JDSegmentControl *segment;
@property (nonatomic, strong) LSPZPagingScrollView *pagingScrollView;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (weak, nonatomic) IBOutlet UILabel *targetCount;
@property (nonatomic, strong) ZBLSRequestManager *requestManager;
@property (nonatomic, strong) DialogTip *dialogTipView;
@end

@implementation LSLiveBroadcasterViewController

- (void)initCustomParam {
    [super initCustomParam];
    
    // Items for tab
    LSUITabBarItem *tabBarItem = [[LSUITabBarItem alloc] init];
    self.tabBarItem = tabBarItem;
    //    self.tabBarItem.title = @"Discover";
    self.tabBarItem.image = [[UIImage imageNamed:@"TabBarHot"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBarHot-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSDictionary *normalColor = [NSDictionary dictionaryWithObject:Color(51, 51, 51, 1) forKey:NSForegroundColorAttributeName];
    NSDictionary *selectedColor = [NSDictionary dictionaryWithObject:Color(52, 120, 247, 1) forKey:NSForegroundColorAttributeName];
    [self.tabBarItem setTitleTextAttributes:normalColor forState:UIControlStateNormal];
    [self.tabBarItem setTitleTextAttributes:selectedColor forState:UIControlStateSelected];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 未读
    self.unreadCountManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadCountManager addDelegate:self];
    self.unreadCount = 0;
    
    self.requestManager = [ZBLSRequestManager manager];
    
    NSArray *title =  @[@"Todos"];
    self.segment = [[JDSegmentControl alloc] initWithNumberOfTitles:title andFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 35) delegate:self isSymmetry:YES isRegularWidth:YES];
    [self.topView addSubview:self.segment];
    
    [self.bottomView addSubview:self.badge];
    
    LSTodosViewController *vc = [[LSTodosViewController alloc] initWithNibName:nil bundle:nil];
    vc.view.frame = self.todosView.frame;
    [self addChildViewController:vc];
    
    self.viewControllers = [NSArray arrayWithObjects:vc, nil];
    
//    CGFloat bottom = self.topView.frame.origin.y + self.topView.frame.size.height;
    self.pagingScrollView = [[LSPZPagingScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 1)];
    self.pagingScrollView.pagingViewDelegate = self;
    self.pagingScrollView.bounces = NO;
    [self.todosView addSubview:self.pagingScrollView];
    
    self.dialogTipView = [DialogTip dialogTip];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getTodayCredit];
    [self getUnreadSheduledBooking];
    [self getCornfirmScheduledBooking];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = COLOR_WITH_16BAND_RGB(0x297AF3);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Dashboard";
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    [self hideNavgationBarBottomLine:YES];

}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self hideNavgationBarBottomLine:NO];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
}


- (void)getTodayCredit {
    [self.requestManager anchorGetTodayCredit:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBTodayCreditItemObject * _Nullable item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.targetCount.hidden = NO;
                self.incomeCount.text = [NSString stringWithFormat:@"%d",item.monthCredit];
                CGFloat progress = self.progressView.frame.size.width * (item.monthProgress / 100.0);
                self.targetCount.text = [NSString stringWithFormat:@"Broadcast days: %d/%d",item.monthCompleted,item.monthTarget];
                self.progressView.progressValue = progress;
            }else {
                  [self.dialogTipView showDialogTip:self.view tipText:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
                self.incomeCount.text = @"-";
                CGFloat progress = 0;
                self.targetCount.hidden = YES;
                self.progressView.progressValue = progress;
            }
     
        });
    }];
    
}

- (void)getCornfirmScheduledBooking {
    [self.requestManager anchorGetScheduleListNoReadNum:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBBookingUnreadUnhandleNumItemObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.bookingCount.text = [NSString stringWithFormat:@"%d",item.scheduledNoReadNum];
            }else {
                self.bookingCount.text = @"-";
            }

        });
    }];

}

- (void)getUnreadSheduledBooking {
    [self.requestManager anchorGetScheduledAcceptNum:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, int scheduledNum) {
        dispatch_async(dispatch_get_main_queue(), ^{
            LSTodosViewController *vc = (LSTodosViewController *)[self.viewControllers objectAtIndex:0];
            vc.unReadBookingCount = scheduledNum;
            [vc.tableView reloadData];
        });
    }];
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
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    if (vc.view != nil) {
        [vc.view removeFromSuperview];
    }
    [pageView removeAllSubviews];
    [vc.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
    [pageView addSubview:vc.view];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    self.curIndex = index;
    [self reportDidShowPage:index];
    [self.segment selectButtonTag:self.curIndex];
}

- (void)segmentControlSelectedTag:(NSInteger)tag {
    self.curIndex = tag;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
}

@end
