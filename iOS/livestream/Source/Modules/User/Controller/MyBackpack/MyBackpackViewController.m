//
//  MyBackpackViewController.m
//  livestream
//
//  Created by Calvin on 17/10/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MyBackpackViewController.h"
#import "JDSegmentControl.h"
#import "LSUserUnreadCountManager.h"
#import "VouchersListViewController.h"
#import "GiftListViewController.h"
#import "MyRidesViewController.h"
#import "PostStampViewController.h"

@interface MyBackpackViewController () <JDSegmentControlDelegate, LSUserUnreadCountManagerDelegate, LSPZPagingScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) JDSegmentControl *segment;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, weak) LSPZPagingScrollView *pagingScrollView;
@property (nonatomic, strong) LSUserUnreadCountManager *unreadCountManager;
@end

@implementation MyBackpackViewController

- (void)dealloc {
    [self.unreadCountManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"MyBackpackViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedStringFromSelf(@"My Backpack");

    NSArray *title = @[NSLocalizedStringFromSelf(@"Post Stamp"), NSLocalizedStringFromSelf(@"Vouchers"), NSLocalizedStringFromSelf(@"My Gifts"), NSLocalizedStringFromSelf(@"My Rides")];

    self.segment = [[JDSegmentControl alloc] initWithNumberOfTitles:title andFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 50) delegate:self isSymmetry:YES isShowbottomLine:YES];
    [self.topView addSubview:self.segment];

    self.unreadCountManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadCountManager addDelegate:self];

    PostStampViewController *vc4 = [[PostStampViewController alloc] initWithNibName:nil bundle:nil];
    vc4.view.frame = self.view.frame;
    [self addChildViewController:vc4];
    
    VouchersListViewController *vc1 = [[VouchersListViewController alloc] initWithNibName:nil bundle:nil];
    vc1.view.frame = self.view.frame;
    [self addChildViewController:vc1];

    GiftListViewController * vc2 = [[GiftListViewController alloc] initWithNibName:nil bundle:nil];
    vc2.view.frame = self.view.frame;
    [self addChildViewController:vc2];

    MyRidesViewController *vc3 = [[MyRidesViewController alloc] initWithNibName:nil bundle:nil];
    vc3.view.frame = self.view.frame;
    [self addChildViewController:vc3];

    self.viewControllers = [NSArray arrayWithObjects:vc4, vc1, vc2, vc3, nil];

    // 跟踪用户行为
    [self reportDidShowPage:self.curIndex];
    
    CGFloat bottom = self.topView.frame.origin.y + self.topView.frame.size.height;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, SCREEN_WIDTH, 1)];
    lineView.backgroundColor =COLOR_WITH_16BAND_RGB(0xE4E4E4);
    [self.view addSubview:lineView];
    LSPZPagingScrollView *pagingScrollView = [[LSPZPagingScrollView alloc] initWithFrame:CGRectMake(0, bottom + 1, SCREEN_WIDTH, SCREEN_HEIGHT - bottom - 1)];
    pagingScrollView.pagingViewDelegate = self;
    pagingScrollView.bounces = NO;
    [self.view addSubview:pagingScrollView];
    self.pagingScrollView = pagingScrollView;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getunreadCount) name:@"MyBackPackGetUnreadCount" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self hideNavgationBarBottomLine:YES];
    [self reportDidShowPage:self.curIndex];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideNavgationBarBottomLine:NO];
}


- (void)getunreadCount
{
    [self.unreadCountManager getBackpackUnreadCount];
}

- (void)segmentControlSelectedTag:(NSInteger)tag {
    self.curIndex = tag;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
   //self.view.userInteractionEnabled = NO;
}

- (void)onGetBackpackUnreadCount:(GetBackPackUnreadNumItemObject *)item {
    //self.view.userInteractionEnabled = YES;
    NSArray *count = @[ [NSString stringWithFormat:@"%d", 0], // 邮票
                        [NSString stringWithFormat:@"%d", item.voucherUnreadNum],
                        [NSString stringWithFormat:@"%d", item.giftUnreadNum],
                        [NSString stringWithFormat:@"%d", item.rideUnreadNum] ];

    [self.segment updateBtnUnreadCount:count];
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

@end
