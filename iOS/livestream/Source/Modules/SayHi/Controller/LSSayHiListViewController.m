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
#import "LSSayHiLeadInfoView.h"

#define NormalNavH 64
#define SepecialNavH 88



@interface LSSayHiListViewController ()<QNSementViewDelegate,LSPZPagingScrollViewDelegate,LSSayHiLeadInfoViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *titleSegment;
@property (strong, nonatomic) QNSementView *segment;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

@end

@implementation LSSayHiListViewController
- (void)initCustomParam {
    [super initCustomParam];
    self.isHideNavBottomLine = YES;
    self.curIndex = 0;
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
    [rightBtn setImage:[UIImage imageNamed:@"LS_Nav_Info"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn addTarget:self action:@selector(pageRightAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.pagingScrollView.pagingViewDelegate = self;
    // 设置取消延迟响应,否则页面的系统按钮高亮状态无效果
    self.pagingScrollView.delaysContentTouches = NO;
    [self setupSegment];
    
    // 监听未读数的刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUnreadNum) name:@"SayHiGetUnreadCount" object:nil];
    
}

- (void)pageRightAction:(UIButton *)btn {
    LSSayHiLeadInfoView *info = [LSSayHiLeadInfoView leadInfoView];
    info.leadInfoDelegate = self;
    [info showSayHiLeadInfoView:self.navigationController.view];
}

- (void)lsSayHiLeadInfoDidClose:(LSSayHiLeadInfoView *)view {
    CGFloat navHeight = NormalNavH;
    if (IS_IPHONE_X) {
        navHeight = SepecialNavH;
    }
    CGFloat rightNavItemWidth = 24;
    
    //创建一个CABasicAnimation对象
    //位移动画
    CABasicAnimation * positionAnim = [CABasicAnimation animation];
    positionAnim.keyPath = @"position";

    positionAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(screenSize.width - rightNavItemWidth,navHeight)];
    // 设置动画执行次数
    positionAnim.repeatCount = 1;
    // 取消动画反弹
    // 设置动画完成的时候不要移除动画
    positionAnim.removedOnCompletion = NO;
    // 设置动画执行完成要保持最新的效果
    positionAnim.fillMode = kCAFillModeForwards;
    positionAnim.duration = 0.5f;
    [view.contentView.layer addAnimation:positionAnim forKey:nil];

    //创建一个基本形变动画
    CABasicAnimation * scaleAnim = [CABasicAnimation animation];
    //kvc设置需要动画的属性
    scaleAnim.keyPath = @"transform.scale";
    //设置该属性的最终装填
    scaleAnim.toValue = @0.0f;
    // 设置动画执行次数
    scaleAnim.repeatCount = 1;
    // 取消动画反弹
    // 设置动画完成的时候不要移除动画
    scaleAnim.removedOnCompletion = NO;
    // 设置动画执行完成要保持最新的效果
    scaleAnim.fillMode = kCAFillModeForwards;
    //设置动画时间
    scaleAnim.duration = 0.5f;
    [view.contentView.layer addAnimation:scaleAnim forKey:nil];
    
    [UIView animateWithDuration:1 animations:^{
        view.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        view.hidden = YES;
        [view removeFromSuperview];
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadUnreadNum];
    [self setNavgationBarBottomLineHidden:YES];
    [self showFirstTimeInfo];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     // 界面出现刷新当前约束,以调整机型适配防止控件大小不准确
    [self.pagingScrollView layoutIfNeeded];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
}

- (void)setupSegment {
    // 创建分栏控件
    NSArray *title = @[NSLocalizedStringFromSelf(@"All"), NSLocalizedStringFromSelf(@"Response")];
    self.segment = [[QNSementView alloc] initWithNumberOfTitles:title andFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 50) delegate:self isSymmetry:YES isShowbottomLine:NO];
    [self.segment updateBtnUnreadCount:@[[NSString stringWithFormat:@"%ld",(long)0],
                                         [NSString stringWithFormat:@"%ld",(long)0]]];
    [self.titleSegment addSubview:self.segment];

}


/**
    是否第一次显示saHi提示
 */
- (void)showFirstTimeInfo {
    NSString *firstTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"sayHiFirstTimeInfo"];
    if (!firstTime) {
        LSSayHiLeadInfoView *info = [LSSayHiLeadInfoView leadInfoView];
        info.leadInfoDelegate = self;
        [info showSayHiLeadInfoView:self.navigationController.view];
        [[NSUserDefaults standardUserDefaults] setObject:@"first" forKey:@"sayHiFirstTimeInfo"];
    }
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
    [self.segment selectButtonTag:self.curIndex];
    
}

@end
