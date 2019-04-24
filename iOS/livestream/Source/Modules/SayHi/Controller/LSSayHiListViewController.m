//
//  LSChatAndInvitationViewController.m
//  livestream
//
//  Created by test on 2018/11/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSSayHiListViewController.h"
#import "QNSementView.h"
#import "LSSayHiAllListViewController.h"
#import "LSSayHiResponseListViewController.h"
#import "LSUserUnreadCountManager.h"


@interface LSSayHiListViewController ()<QNSementViewDelegate,LSPZPagingScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *titleSegment;
@property (strong, nonatomic) QNSementView *segment;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

@end

@implementation LSSayHiListViewController
- (void)initCustomParam {
    [super initCustomParam];
    self.isHideNavBottomLine = YES;
    self.curIndex = 1;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Say Hi";
    
    LSSayHiAllListViewController * vc1 = [[LSSayHiAllListViewController alloc] initWithNibName:nil bundle:nil];
    vc1.isHideNavBottomLine = self.isHideNavBottomLine;
    vc1.view.frame = self.view.frame;
    [self addChildViewController:vc1];
    
    LSSayHiResponseListViewController *vc2 = [[LSSayHiResponseListViewController alloc] initWithNibName:nil bundle:nil];
    vc2.isHideNavBottomLine = self.isHideNavBottomLine;
    vc2.view.frame = self.view.frame;
    [self addChildViewController:vc2];
    
    self.viewControllers = [NSArray arrayWithObjects:vc1,vc2,nil];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"LS_Chat_SystemTips"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn addTarget:self action:@selector(pageRightAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.pagingScrollView.pagingViewDelegate = self;
    [self setupSegment];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUnreadNum) name:@"SayHiGetUnreadCount" object:nil];
    
}

- (void)pageRightAction:(UIButton *)btn {
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadUnreadNum];
    [self setNavgationBarBottomLineHidden:YES];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];



}

- (void)setupSegment {
//    // 创建分栏控件
    NSArray *title = @[NSLocalizedStringFromSelf(@"All"), NSLocalizedStringFromSelf(@"Response")];
    self.segment = [[QNSementView alloc] initWithNumberOfTitles:title andFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 50) delegate:self isSymmetry:YES isShowbottomLine:NO];
    [self.titleSegment addSubview:self.segment];

}

#pragma mark - 数据逻辑
- (void)reloadUnreadNum {
    [[LSUserUnreadCountManager shareInstance] getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject * _Nonnull unreadModel) {
        [self.segment updateBtnUnreadCount:@[[NSString stringWithFormat:@"%ld",(long)0],
                                             [NSString stringWithFormat:@"%ld",(long)unreadModel.sayHiNoreadNum]]];
    }];

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

@end
