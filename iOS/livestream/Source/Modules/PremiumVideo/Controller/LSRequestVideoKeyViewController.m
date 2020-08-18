//
//  LSRequestVideoKeyViewController.m
//  livestream
//
//  Created by Albert on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSRequestVideoKeyViewController.h"
#import "QNSementView.h"
#import "LSSayHiAllListViewController.h"
#import "LSSayHiResponseListViewController.h"
#import "LSAccessKeyRequestViewController.h"
#import "LSPremiumUnlockViewController.h"
#import "LSUserUnreadCountManager.h"
#import "GetTotalNoreadNumRequest.h"

@interface LSRequestVideoKeyViewController ()<QNSementViewDelegate,LSPZPagingScrollViewDelegate,LSUserUnreadCountManagerDelegate>

@property (strong, nonatomic) QNSementView *segment;

@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;

@property (nonatomic, strong) LSUserUnreadCountManager *unreadManager;

@end

@implementation LSRequestVideoKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Requested to View and Unlocked Videos";
    
    self.curIndex = 0;
    
    self.unreadManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadManager addDelegate:self];
    
    LSAccessKeyRequestViewController *vc1 = [[LSAccessKeyRequestViewController alloc] initWithNibName:nil bundle:nil];
    vc1.view.frame = self.mainView.frame;
    [self addChildViewController:vc1];
    
    LSPremiumUnlockViewController *vc2 = [[LSPremiumUnlockViewController alloc] initWithNibName:nil bundle:nil];
    vc2.view.frame = self.mainView.frame;
    [self addChildViewController:vc2];
    
    self.viewControllers = [NSArray arrayWithObjects:vc1,vc2,nil];

    self.pagingScrollView.pagingViewDelegate = self;
    // 设置取消延迟响应,否则页面的系统按钮高亮状态无效果
    self.pagingScrollView.delaysContentTouches = NO;
    
    [self setupSegment];
}

- (void)setupSegment {
    // 创建分栏控件
    NSArray *title = @[NSLocalizedStringFromSelf(@"Access Key Requests"), NSLocalizedStringFromSelf(@"Unlocked Videos")];
    self.segment = [[QNSementView alloc] initWithNumberOfTitles:title andFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 50) delegate:self isSymmetry:YES isShowbottomLine:NO];
    [self.segment setTitleFont:[UIFont fontWithName:@"ArialMT" size:14]];
    [self.segment setTitleSelectFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    [self.segment setTextNormalColor:[UIColor colorWithRed:56/255.f green:56/255.f blue:56/255.f alpha:1] andSelectedColor:[UIColor colorWithRed:37/255.f green:111/255.f blue:241/255.f alpha:1]];
    [self.titleSegment addSubview:self.segment];
    
    int unreadCount = [self.unreadManager getUnreadNum:LSUnreadType_Video];
    [self.segment updateUnreadStatus:@[[NSString stringWithFormat:@"%d",unreadCount],@"0"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadCount:) name:@"kUpdateUnreadCountNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     // 界面出现刷新当前约束,以调整机型适配防止控件大小不准确
    [self.pagingScrollView layoutIfNeeded];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
}

-(void)dealloc
{
    [self.unreadManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kUpdateUnreadCountNotification" object:nil];
}

-(void)updateUnreadCount:(NSNotification *)notif
{
    [self.unreadManager getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel){
        [self.segment updateUnreadStatus:@[[NSString stringWithFormat:@"%d",unreadModel.videoNum],@"0"]];
    }];
}

#pragma mark - UnreadNumManagerDelegate
- (void)reloadUnreadView:(TotalUnreadNumObject *)model {
    [self.segment updateUnreadStatus:@[[NSString stringWithFormat:@"%d",model.videoNum],@"0"]];
}
#pragma mark - 顶部导航tab 回调 (QNSementViewDelegate)
- (void)segmentControlSelectedTag:(NSInteger)tag
{
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
