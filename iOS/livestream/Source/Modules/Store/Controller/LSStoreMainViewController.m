//
//  LSStoreMainViewController.m
//  livestream
//
//  Created by Calvin on 2019/9/29.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSStoreMainViewController.h"
#import "QNSementView.h"
#import "LSPZPagingScrollView.h"

#import "LSStoreListViewController.h"
#import "LSDeliveryListViewController.h"

#import "LSAddresseeOrderManager.h"
#import "LSNavTitleView.h"

@interface LSStoreMainViewController ()<QNSementViewDelegate,LSPZPagingScrollViewDelegate,LSDeliveryListViewControllerDelegate>
@property (strong, nonatomic) QNSementView *segment;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;
@end

@implementation LSStoreMainViewController

- (void)dealloc {
    [[LSAddresseeOrderManager manager] removeAddressee];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.edgesForExtendedLayout = UIRectEdgeNone;
        
    LSStoreListViewController * storeVC = [[LSStoreListViewController alloc]initWithNibName:nil bundle:nil];
    [self addChildViewController:storeVC];
    
    LSDeliveryListViewController * deliveryVC = [[LSDeliveryListViewController alloc]initWithNibName:nil bundle:nil];
    deliveryVC.deliveryDelegate = self;
    [self addChildViewController:deliveryVC];
    
    self.viewControllers = [NSArray arrayWithObjects:storeVC,deliveryVC, nil];
    
    self.pagingScrollView.pagingViewDelegate = self;
       // 设置取消延迟响应,否则页面的系统按钮高亮状态无效果
       self.pagingScrollView.delaysContentTouches = NO;

    [self setupSegment];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pagingScrollView layoutIfNeeded];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
 
- (void)setupSegment {
    
    LSNavTitleView * titleView = [[LSNavTitleView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 88, 44)];
    //titleView.backgroundColor = [UIColor redColor];
     //创建分栏控件
    self.segment = [[QNSementView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 88, 44)];
    self.segment.titleArray = @[NSLocalizedStringFromSelf(@"Store"), NSLocalizedStringFromSelf(@"Delivery")];
    [self.segment setTextNormalColor:COLOR_WITH_16BAND_RGB(0x383838) andSelectedColor:COLOR_WITH_16BAND_RGB(0x383838)];
    [self.segment setLineNormalColor:[UIColor clearColor] andelectedColor:COLOR_WITH_16BAND_RGB(0x297AF3)];
    [self.segment newTitleBtnIsSymmetry:YES];
    self.segment.delegate = self;
    [titleView addSubview:self.segment];

     self.navigationItem.titleView = titleView;
}

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
    
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    CGFloat pageViewHeight = pageView.self.frame.size.height;
    
    if (vc.view != nil) {
        [vc.view removeFromSuperview];
    }
    
    [pageView removeAllSubviews];
    
    [vc.view setFrame:CGRectMake(0, 0, pageView.self.frame.size.width, pageViewHeight)];
    [pageView addSubview:vc.view];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    self.curIndex = index;
    [self reportDidShowPage:index];
    [self.segment selectButtonTag:self.curIndex];
    
}


- (void)lsDeliveryListViewControllerDidShowGiftStore:(LSDeliveryListViewController *)vc {
        [self.pagingScrollView displayPagingViewAtIndex:0 animated:NO];
}
@end
