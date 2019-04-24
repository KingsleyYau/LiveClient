//
//  ChatAccessoryListViewController.m
//  dating
//
//  Created by Calvin on 2019/3/21.
//  Copyright © 2019 qpidnetwork. All rights reserved.
//

#import "LSChatAccessoryListViewController.h"
#import "LSChatSecretPhotoViewController.h"
#import "LSChatDetailVideoViewController.h"
#import "LSAddCreditsViewController.h"
#import "QNMessage.h"
 #import "Masonry.h"
@interface LSChatAccessoryListViewController ()<LSPZPagingScrollViewDelegate,LSChatSecretPhotoViewControllerDelegate,LSChatDetailVideoViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray * viewArray;
@end

@implementation LSChatAccessoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewArray = [NSMutableArray array];

    self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"LS_Nav_Back_w"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, (IS_IPHONE_X)?40:20, 40, 40);
    [backBtn addTarget:self action:@selector(backDid) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    for (int index = 0; index < self.items.count; index++) {
        QNMessage *msg = self.items[index];
        if (msg.type == MessageTypePhoto) {
            LSChatSecretPhotoViewController *vc = [[LSChatSecretPhotoViewController alloc] initWithNibName:nil bundle:nil];
            vc.msgItem = msg.liveChatMsgItemObject;
            vc.viewDelegate = self;
            [self.viewArray addObject:vc];
        }
        if (msg.type == MessageTypeVideo) {
            LSChatDetailVideoViewController * vc = [[LSChatDetailVideoViewController alloc]initWithNibName:nil bundle:nil];
            if (msg.recentVideoItemObject) {
                vc.recentItem = msg.recentVideoItemObject;
            } else {
                vc.msgItem = msg.liveChatMsgItemObject;
            }
            vc.viewDelegate = self;
            [self.viewArray addObject:vc];
        }
    }
    
    if (@available(iOS 11, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)initCustomParam {
    [super initCustomParam];
    self.isShowNavBar = NO;
}

- (void)photoDetailspushAddCreditsViewController {
    LSAddCreditsViewController * vc = [[LSAddCreditsViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)videoDetailspushAddCreditsViewController {
    [self photoDetailspushAddCreditsViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scrollView displayPagingViewAtIndex:self.row animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated  {
    [super viewWillDisappear:animated];
}

- (void)backDid {
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -PZPagingScrollViewDelegate
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    return self.items.count;
}

- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)];
    return view;
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index{
    UIViewController *vc = [self.viewArray objectAtIndex:index];
    CGFloat pageViewHeight = pageView.self.frame.size.height;
    
    if (vc.view != nil) {
        [vc.view removeFromSuperview];
    }
    
    [pageView removeAllSubviews];
    
    if (IS_IPHONE_X) {
        pageViewHeight = pageViewHeight - 34;
    }
    
    [vc.view setFrame:CGRectMake(0, 0, pageView.self.frame.size.width, pageViewHeight)];
    [vc beginAppearanceTransition:YES animated:NO];
    [pageView addSubview:vc.view];
    [vc endAppearanceTransition];
    [vc didMoveToParentViewController:self];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index{
    
}

@end
