//
//  LSMyReservationsViewController.m
//  livestream
//
//  Created by Calvin on 17/10/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSMyReservationsViewController.h"
#import "JDSegmentControl.h"
#import "LSMyReservationsPageViewController.h"
#import "LSSessionRequestManager.h"
#import "ManBookingUnreadUnhandleNumRequest.h"
#import "LSImManager.h"
@interface LSMyReservationsViewController () <JTSegmentControlDelegate, JDSegmentControlDelegate, LSPZPagingScrollViewDelegate,IMLiveRoomManagerDelegate>
@property (nonatomic, strong) LSPZPagingScrollView * pagingScrollView;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, assign) NSInteger curIndex;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) JDSegmentControl *segment;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) LSImManager * imManager;
@end

@implementation LSMyReservationsViewController

- (void)dealloc {
    [self.imManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sessionManager = [LSSessionRequestManager manager];
    
    self.imManager = [LSImManager manager];
    [self.imManager.client addDelegate:self];
    
    self.title = NSLocalizedStringFromSelf(@"MY_TITLE");
    NSArray *title = @[ NSLocalizedStringFromSelf(@"NEW"), NSLocalizedStringFromSelf(@"SEND"), NSLocalizedStringFromSelf(@"SCHED"), NSLocalizedStringFromSelf(@"HISTORY") ];
    self.segment = [[JDSegmentControl alloc] initWithNumberOfTitles:title andFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 50) delegate:self isSymmetry:YES];
    [self.topView addSubview:self.segment];

    LSMyReservationsPageViewController *vc1 = [[LSMyReservationsPageViewController alloc] initWithNibName:nil bundle:nil];
    vc1.type = BOOKINGLISTTYPE_WAITFANSHANDLEING;
    vc1.view.frame = self.view.frame;
    vc1.mainVC = self;
    [self addChildViewController:vc1];

    LSMyReservationsPageViewController *vc2 = [[LSMyReservationsPageViewController alloc] initWithNibName:nil bundle:nil];
    vc2.view.frame = self.view.frame;
    vc2.type = BOOKINGLISTTYPE_WAITANCHORHANDLEING;
    vc2.mainVC = self;
    [self addChildViewController:vc2];

    LSMyReservationsPageViewController *vc3 = [[LSMyReservationsPageViewController alloc] initWithNibName:nil bundle:nil];
    vc3.view.frame = self.view.frame;
    vc3.type = BOOKINGLISTTYPE_COMFIRMED;
    vc3.mainVC = self;
    [self addChildViewController:vc3];

    LSMyReservationsPageViewController *vc4 = [[LSMyReservationsPageViewController alloc] initWithNibName:nil bundle:nil];
    vc4.view.frame = self.view.frame;
    vc4.type = BOOKINGLISTTYPE_HISTORY;
    vc4.mainVC = self;
    [self addChildViewController:vc4];

    self.viewControllers = [NSArray arrayWithObjects:vc1, vc2, vc3, vc4, nil];

    CGFloat bottom = self.topView.frame.origin.y + self.topView.frame.size.height;
    self.pagingScrollView = [[LSPZPagingScrollView alloc] initWithFrame:CGRectMake(0, bottom, SCREEN_WIDTH, SCREEN_HEIGHT - bottom)];
    self.pagingScrollView.pagingViewDelegate = self;
    self.pagingScrollView.bounces = NO;
    [self.view addSubview:self.pagingScrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
}

- (void)getunreadCount
{
    ManBookingUnreadUnhandleNumRequest * request = [[ManBookingUnreadUnhandleNumRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * errmsg, BookingUnreadUnhandleNumItemObject * item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *count = @[ [NSString stringWithFormat:@"%d", item.pendingNoReadNum],
                                @"",
                                [NSString stringWithFormat:@"%d", item.scheduledNoReadNum],
                                [NSString stringWithFormat:@"%d", item.historyNoReadNum] ];
            
            [self.segment updateBtnUnreadCount:count];
        });
    };
    
    [self.sessionManager sendRequest:request];
}

- (void)segmentControlSelectedTag:(NSInteger)tag {
    self.curIndex = tag;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
    //self.view.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    [vc.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
    [pageView addSubview:vc.view];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.curIndex = index;
    [self reportDidShowPage:index];
    [self.segment selectButtonTag:self.curIndex];
}

#pragma mark - 预约更新通知
//接收主播预约私密邀请通知
- (void)onRecvScheduledInviteUserNotice:(NSString*)inviteId anchorId:(NSString*)anchorId nickName:(NSString*)nickName avatarImg:(NSString*)avatarImg msg:(NSString*)msg
{
    [self getunreadCount];
}

//接收预约私密邀请回复通知
- (void)onRecvSendBookingReplyNotice:(ImBookingReplyObject*)item
{
    [self getunreadCount];
}

//接收预约开始倒数通知
- (void)onRecvBookingNotice:(NSString*)roomId userId:(NSString*)userId nickName:(NSString*)nickName avatarImg:(NSString*)avatarImg  leftSeconds:(int)leftSeconds
{
    [self getunreadCount];
}

@end
