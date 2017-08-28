//
//  HomePageViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "HomePageViewController.h"

#import "FollowingViewController.h"
#import "HotViewController.h"
#import "DiscoverViewController.h"
#import "SearchViewController.h"
#import "ChatViewController.h"
#import "ChatListViewController.h"

@interface HomePageViewController () <JTSegmentControlDelegate>

@property (nonatomic, strong) NSArray<UIViewController*> *viewControllers;

@property (nonatomic, assign) NSInteger curIndex;

@property(nonatomic, strong) JTSegmentControl* categoryControl;

@end

@implementation HomePageViewController

#pragma mark - 界面初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    FollowingViewController* vc1 = [[FollowingViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:vc1];
    
    HotViewController* vc2 = [[HotViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:vc2];
    
    DiscoverViewController* vc3 = [[DiscoverViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:vc3];
    
    self.viewControllers = [NSArray arrayWithObjects:vc1, vc2, vc3, nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置不被NavigationBar和TabBar遮挡
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidAppear:(BOOL)animated {
    if( !self.viewDidAppearEver ) {
        // 第一次进入, 界面已经出现
        [self reloadData:YES animated:NO];
    }
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCustomParam {
    [super initCustomParam];
    
    // 设置导航栏返回按钮
    [self setBackleftBarButtonItemOffset:15];
    
//    self.title = @"Home";
    self.tabBarItem.image = [UIImage imageNamed:@"TabBarHome"];
    
    self.curIndex = 0;
    
    // 设置标题
    CGFloat width = [UIScreen mainScreen].bounds.size.width - (44 * 2);
    CGRect frame = CGRectMake(0, 0, width, 44);
    JTSegmentControl* categoryControl = [[JTSegmentControl alloc] initWithFrame:frame];
    categoryControl.delegate = self;
    categoryControl.autoScrollWhenIndexChange = YES;
    categoryControl.items = [NSArray arrayWithObjects:@"Following", @"Hot", @"Discover", nil];
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
    
    UIButton* navRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    image = [UIImage imageNamed:@"Home_Nav_Btn_Search"];
    [navRightButton setImage:image forState:UIControlStateNormal];
    [navRightButton sizeToFit];
    [navRightButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    [array addObject:barButtonItem];
    
    [self.navigationItem setRightBarButtonItems:array animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 界面事件
- (IBAction)searchAction:(id)sender {
    
//    SearchViewController *searchController = [[SearchViewController alloc]init];
//    [self.navigationController pushViewController:searchController animated:YES];
    
    ChatListViewController *listViewController = [[ChatListViewController alloc]init];
    [self.navigationController pushViewController:listViewController animated:YES];
    
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView animated:(BOOL)animated {
    if( isReloadView ) {
        if( animated ) {
            self.navigationController.navigationBar.userInteractionEnabled = NO;
        }
        
        [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:animated];
        
        [self setupNavigationBar];
    }
}

#pragma mark - 画廊回调 (PZPagingScrollViewDelegate)
- (Class)pagingScrollView:(PZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(PZPagingScrollView *)pagingScrollView {
    return (nil == self.viewControllers)?0:self.viewControllers.count;
}

- (UIView *)pagingScrollView:(PZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)];
    return view;
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    UIViewController* vc = [self.viewControllers objectAtIndex:index];
    if( vc.view != nil ) {
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

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.curIndex = index;
    
    [self.categoryControl moveTo:self.curIndex];
    [self setupNavigationBar];
    
}

#pragma mark - 分类选择器回调 (PZPagingScrollViewDelegate)
- (void)didSelectedWithSegement:(JTSegmentControl * _Nonnull)segement index:(NSInteger)index {
    self.curIndex = index;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
}

@end
