//
//  LSChatAndInvitationViewController.m
//  livestream
//
//  Created by test on 2018/11/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "QNChatAndInvitationViewController.h"
#import "QNChatListViewController.h"
#import "QNInvitationListViewController.h"
#import "QNContactManager.h"
#import "QNSementView.h"

typedef enum : NSUInteger {
    ChatListTypeChat = 0,
    ChatListTypeInvitation
} ChatListType;


@interface QNChatAndInvitationViewController ()<QNSementViewDelegate,LSPZPagingScrollViewDelegate,QNContactManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *titleSegment;
@property (strong, nonatomic) QNSementView *segment;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

@end

@implementation QNChatAndInvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.curIndex = 0;
    [[QNContactManager manager] addDelegate:self];
    
    self.title = @"Chat";
    
    QNChatListViewController * vc1 = [[QNChatListViewController alloc] initWithNibName:nil bundle:nil];
    vc1.view.frame = self.view.frame;
    [self addChildViewController:vc1];
    
    QNInvitationListViewController *vc2 = [[QNInvitationListViewController alloc] initWithNibName:nil bundle:nil];
    vc2.view.frame = self.view.frame;
    [self addChildViewController:vc2];
    
    self.viewControllers = [NSArray arrayWithObjects:vc1,vc2,nil];
    
    self.pagingScrollView.pagingViewDelegate = self;
    [self setupSegment];
    
    [self reportDidShowPage:self.curIndex];

}

- (void)dealloc {
    [[QNContactManager manager] removeDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideNavgationBarBottomLine:YES];
    [self reloadUnreadNum];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideNavgationBarBottomLine:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.pagingScrollView layoutIfNeeded];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];

}

- (void)setupSegment {
//    // 创建分栏控件
    NSArray *title = @[NSLocalizedStringFromSelf(@"Chat List"), NSLocalizedStringFromSelf(@"Invitation")];
    self.segment = [[QNSementView alloc] initWithNumberOfTitles:title andFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 50) delegate:self isSymmetry:YES isShowbottomLine:NO];
    [self.titleSegment addSubview:self.segment];

}

#pragma mark - 数据逻辑

- (void)reloadUnreadNum {
    NSInteger chatlistUnreadCount = [[QNContactManager manager] getChatListUnreadCount];
    NSInteger invitationUnreadCount = [QNContactManager manager].inviteItems.count;
    if (invitationUnreadCount > 0) {
        invitationUnreadCount = -1;
    }
    [self.segment updateBtnUnreadCount:@[[NSString stringWithFormat:@"%ld",(long)chatlistUnreadCount],
                                         [NSString stringWithFormat:@"%ld",(long)invitationUnreadCount]]];
}


- (void)onChangeRecentContactStatus:(QNContactManager *)manager {
    [self reloadUnreadNum];

}


- (void)onChangeInviteList:(QNContactManager *)manager {
    [self reloadUnreadNum];

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
