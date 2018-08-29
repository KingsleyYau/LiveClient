//
//  HangoutInvitePageViewController.m
//  livestream
//
//  Created by Max on 2018/5/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangoutInvitePageViewController.h"

@interface HangoutInvitePageViewController () <JTSegmentControlDelegate, LSPZPagingScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIView *segmentView;
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;
@property (nonatomic, strong) IBOutlet JTSegmentControl *segment;

@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) NSArray<JTSegmentItem *> *sliderFixArray;
@property (nonatomic, strong) NSArray<UIViewController *> *vcFixArray;

@end

@implementation HangoutInvitePageViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.curIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 填充固定分栏
    NSMutableArray<JTSegmentItem *> *array = [NSMutableArray array];
    JTSegmentItem *item = nil;
    item = [[JTSegmentItem alloc] initWithImage:nil selectedImage:nil title:NSLocalizedStringFromSelf(@"Online")];
    [array addObject:item];
    item = [[JTSegmentItem alloc] initWithImage:nil selectedImage:nil title:NSLocalizedStringFromSelf(@"Following")];
    [array addObject:item];
    item = [[JTSegmentItem alloc] initWithImage:nil selectedImage:nil title:NSLocalizedStringFromSelf(@"Watched")];
    [array addObject:item];
    self.sliderFixArray = array;
    
    // 填充固定分页内容
    HangoutInviteTableViewController *vc0 = [[HangoutInviteTableViewController alloc] initWithNibName:nil bundle:nil];
    vc0.inviteType = HANGOUTANCHORLISTTYPE_ONLINEANCHOR;
    [self addChildViewController:vc0];
    
    HangoutInviteTableViewController *vc1 = [[HangoutInviteTableViewController alloc] initWithNibName:nil bundle:nil];
    vc1.inviteType = HANGOUTANCHORLISTTYPE_FOLLOW;
    [self addChildViewController:vc1];
    
    HangoutInviteTableViewController *vc2 = [[HangoutInviteTableViewController alloc] initWithNibName:nil bundle:nil];
    vc2.inviteType = HANGOUTANCHORLISTTYPE_WATCHED;
    [self addChildViewController:vc2];
    
    self.vcFixArray = [NSArray arrayWithObjects:vc0, vc1, vc2, nil];
    
    // 初始化分栏
    [self setupSegment];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 加载默认页
    [self reloadData];
}

- (void)setupSegment {
    // 创建分栏控件
    CGRect frame = CGRectMake(0, 0, self.segmentView.frame.size.width, self.segmentView.frame.size.height);
//    self.segment = [[JTSegmentControl alloc] initWithFrame:frame];
    self.segment = [[JTSegmentControl alloc] init];
    self.segment.frame = frame;
    self.segment.sliderViewColor = COLOR_WITH_16BAND_RGB(0x05c775);
    self.segment.font = [UIFont systemFontOfSize:12];
    self.segment.selectedFont = [UIFont systemFontOfSize:12];
    self.segment.itemTextColor = [UIColor blackColor];
    self.segment.itemBackgroundColor = [UIColor clearColor];
    self.segment.itemSelectedTextColor = COLOR_WITH_16BAND_RGB(0x05c775);
    self.segment.itemSelectedBackgroundColor = [UIColor clearColor];
    self.segment.bounces = YES;
    self.segment.autoAdjustWidth = YES;
//    self.segment.itemWidthCustom = 100;
    self.segment.delegate = self;
    
    [self.segmentView addSubview:self.segment];
}

#pragma mark - 数据逻辑
- (void)reloadData {
    self.curIndex = 0;
    // 填充固定分栏内容
    NSMutableArray *sliderArray = [NSMutableArray arrayWithArray:self.sliderFixArray];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.vcFixArray];
    // 填充好友分栏和分页
    if( self.anchorIdArray.count > 0 ) {
        for(HangoutInviteAnchor *item in self.anchorIdArray) {
            NSString *title = [NSString stringWithFormat:@"%@'s Friend", item.anchorName];
            JTSegmentItem *segmentItem = [[JTSegmentItem alloc] initWithImage:nil selectedImage:nil title:title];
            // 填充好友分栏内容
            [sliderArray addObject:segmentItem];
            
            // 填充好友分页内容
            HangoutInviteTableViewController *vc = [[HangoutInviteTableViewController alloc] initWithNibName:nil bundle:nil];
            vc.inviteType = HANGOUTANCHORLISTTYPE_FRIEND;
            vc.anchorId = item.anchorId;
            [self addChildViewController:vc];
            [viewControllers addObject:vc];
        }
    }
    self.segment.items = sliderArray;
    [self.segment setupViewOpen];
    
    // 选中默认分页界面
    self.viewControllers = viewControllers;
    for(HangoutInviteTableViewController *vc in self.viewControllers) {
        vc.inviteDelegate = self.inviteDelegate;
        [vc reloadInviteList];
    }
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
}

#pragma mark - 分栏委托(JTSegmentControlDelegate)
- (void)didSelectedWithSegement:(JTSegmentControl * _Nonnull)segement index:(NSInteger)index {
    if( self.curIndex != index ) {
        self.curIndex = index;
        [self.pagingScrollView displayPagingViewAtIndex:index animated:YES];
    }
}

#pragma mark - 分页委托(LSPZPagingScrollViewDelegate)
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    return self.viewControllers.count;
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
    
    [pageView addSubview:vc.view];
    [vc.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pageView);
        make.left.equalTo(pageView);
        make.width.equalTo(pageView);
        make.bottom.equalTo(pageView);
    }];
    // 使约束生效
    [vc.view layoutSubviews];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    if( self.curIndex != index ) {
        self.curIndex = index;
        [self.segment moveTo:index animated:YES];
    }
}

@end
