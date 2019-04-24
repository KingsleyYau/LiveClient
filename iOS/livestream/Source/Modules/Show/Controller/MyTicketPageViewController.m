//
//  MyTicketPageViewController.m
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "MyTicketPageViewController.h"
#import "JDSegmentControl.h"
#import "MyTicketsViewController.h"
@interface MyTicketPageViewController () <JDSegmentControlDelegate, LSPZPagingScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic, strong) JDSegmentControl *segment;
@property (nonatomic, strong) LSPZPagingScrollView *pagingScrollView;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@end

@implementation MyTicketPageViewController
- (void)initCustomParam {
    [super initCustomParam];
    self.isHideNavBottomLine = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedStringFromSelf(@"My Tickets");
    NSArray *title = @[ NSLocalizedStringFromSelf(@"Unused"), NSLocalizedStringFromSelf(@"History") ];
    self.segment = [[JDSegmentControl alloc] initWithNumberOfTitles:title andFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 50) delegate:self isSymmetry:YES isShowbottomLine:YES];
    [self.topView addSubview:self.segment];

    MyTicketsViewController *vc1 = [[MyTicketsViewController alloc] initWithNibName:nil bundle:nil];
    vc1.isHideNavBottomLine = self.isHideNavBottomLine;
    vc1.sortType = PROGRAMLISTTYPE_BUYTICKET;
    vc1.view.frame = self.view.frame;
    [self addChildViewController:vc1];

    MyTicketsViewController *vc2 = [[MyTicketsViewController alloc] initWithNibName:nil bundle:nil];
    vc2.isHideNavBottomLine = self.isHideNavBottomLine;
    vc2.sortType = PROGRAMLISTTYPE_HISTORY;
    vc2.view.frame = self.view.frame;
    [self addChildViewController:vc2];

    self.viewControllers = [NSArray arrayWithObjects:vc1, vc2, nil];

    CGFloat bottom = self.topView.frame.origin.y + self.topView.frame.size.height;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = COLOR_WITH_16BAND_RGB(0xE4E4E4);
    [self.view addSubview:lineView];
    self.pagingScrollView = [[LSPZPagingScrollView alloc] initWithFrame:CGRectMake(0, bottom + 1, SCREEN_WIDTH, SCREEN_HEIGHT - bottom - 1)];
    self.pagingScrollView.pagingViewDelegate = self;
    self.pagingScrollView.bounces = NO;
    [self.view addSubview:self.pagingScrollView];
    // 跟踪用户行为
    [self reportDidShowPage:self.curIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavgationBarBottomLineHidden:YES];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark 头部点击事件
- (void)segmentControlSelectedTag:(NSInteger)tag {
    self.curIndex = tag;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
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
@end
