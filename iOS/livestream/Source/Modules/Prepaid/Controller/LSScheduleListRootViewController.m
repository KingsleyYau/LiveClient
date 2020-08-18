//
//  LSScheduleListRootViewController.m
//  livestream
//
//  Created by Calvin on 2020/4/15.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleListRootViewController.h"
#import "JDSegmentControl.h"
#import "LSScheduleListViewController.h"
#import "LSUserUnreadCountManager.h"
#import "LSSeclectSendScheduleViewController.h"
@interface LSScheduleListRootViewController ()<JDSegmentControlDelegate, LSPZPagingScrollViewDelegate,LSUserUnreadCountManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) JDSegmentControl *segment;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, weak) LSPZPagingScrollView *pagingScrollView;
@property (weak, nonatomic) IBOutlet UIButton *scheduleBtn;
 
@end

@implementation LSScheduleListRootViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromSelf(@"NAVTITLE");
    
    NSArray *title = @[ NSLocalizedStringFromSelf(@"Pending"), NSLocalizedStringFromSelf(@"Confirmed"), NSLocalizedStringFromSelf(@"Declined"), NSLocalizedStringFromSelf(@"Expired") ];

    self.segment = [[JDSegmentControl alloc] initWithNumberOfTitles:title andFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 44) delegate:self isSymmetry:YES isShowbottomLine:YES];
    [self.topView addSubview:self.segment];
    
    LSScheduleListViewController * vc1 = [[LSScheduleListViewController alloc]initWithNibName:nil bundle:nil];
    vc1.view.frame = self.view.frame;
    vc1.type = ScheduleType_Pending;
    vc1.isHideNavBottomLine = self.isHideNavBottomLine;
    [self addChildViewController:vc1];
    
    LSScheduleListViewController * vc2 = [[LSScheduleListViewController alloc]initWithNibName:nil bundle:nil];
    vc2.view.frame = self.view.frame;
    vc2.type = ScheduleType_Confirmed;
    vc2.isHideNavBottomLine = self.isHideNavBottomLine;
    [self addChildViewController:vc2];
    
    LSScheduleListViewController * vc3 = [[LSScheduleListViewController alloc]initWithNibName:nil bundle:nil];
    vc3.view.frame = self.view.frame;
    vc3.type = ScheduleType_Declined;
    vc3.isHideNavBottomLine = self.isHideNavBottomLine;
    [self addChildViewController:vc3];
    
    LSScheduleListViewController * vc4 = [[LSScheduleListViewController alloc]initWithNibName:nil bundle:nil];
    vc4.view.frame = self.view.frame;
    vc4.type = ScheduleType_Expired;
    vc4.isHideNavBottomLine = self.isHideNavBottomLine;
    [self addChildViewController:vc4];
    
    self.viewControllers = [NSArray arrayWithObjects:vc1, vc2, vc3, vc4, nil];
    
    CGFloat bottom = self.topView.frame.origin.y + self.topView.frame.size.height;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = COLOR_WITH_16BAND_RGB(0xE4E4E4);
    [self.view addSubview:lineView];
    LSPZPagingScrollView *pagingScrollView = [[LSPZPagingScrollView alloc] initWithFrame:CGRectMake(0, bottom + 1, SCREEN_WIDTH, SCREEN_HEIGHT - bottom - 1)];
    pagingScrollView.pagingViewDelegate = self;
    pagingScrollView.bounces = NO;
    [self.view addSubview:pagingScrollView];
    self.pagingScrollView = pagingScrollView;
    
    [self.view bringSubviewToFront:self.scheduleBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getunreadCount) name:@"ReloadScheduleListCount" object:nil];
}

- (void)initCustomParam {
    [super initCustomParam];
    self.isHideNavBottomLine = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
    [self setNavgationBarBottomLineHidden:YES];
    [self getunreadCount];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setNavgationBarBottomLineHidden:(BOOL)isHide {
    [super setNavgationBarBottomLineHidden:YES];
}

- (void)segmentControlSelectedTag:(NSInteger)tag {
    self.curIndex = tag;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
}

- (void)getunreadCount {
    
   [[LSUserUnreadCountManager shareInstance] getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
       [self.segment updateBtnUnreadNum:@[
        [NSString stringWithFormat:@"%d",unreadModel.schedulePendingUnreadNum],
        [NSString stringWithFormat:@"%d",unreadModel.scheduleConfirmedUnreadNum],
        @"0",
        @"0"
       ]];
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
    [self.segment selectButtonTag:self.curIndex];
}

- (IBAction)scheduleIconBtnDid:(UIButton *)sender {
    //TODO:发送预付费
    LSSeclectSendScheduleViewController *vc = [[LSSeclectSendScheduleViewController alloc] initWithNibName:nil bundle:nil];
    [vc showScheduleView:self.navigationController];
}

@end
