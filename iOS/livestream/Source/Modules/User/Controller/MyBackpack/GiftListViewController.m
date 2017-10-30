//
//  GiftListViewController.m
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftListViewController.h"
#import "GiftListRequest.h"
@interface GiftListViewController ()<UIScrollViewRefreshDelegate>

@property (weak, nonatomic) IBOutlet GiftListWaterfallView *giftListWaterfallView;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@end

@implementation GiftListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.sessionManager = [LSSessionRequestManager manager];
    
    [self.giftListWaterfallView initPullRefresh:self pullDown:YES pullUp:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getGiftList];
}

/**
 *  下拉刷新
 */
- (void)pullDownRefresh {
    
    [self getGiftList];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getGiftList
{
    [self showLoading];
    GiftListRequest * request = [[GiftListRequest alloc]init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<BackGiftItemObject *> * _Nullable array, int totalCount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                [self.giftListWaterfallView finishPullDown:YES];
                if (success) {
                    self.giftListWaterfallView.items = array;
                    [self.giftListWaterfallView reloadData];
                    
                    if (self.giftListWaterfallView.items.count == 0) {
                          [self showInfoViewMsg:@"No Gifts"];
                    }
                }
                else
                {
                       [self showInfoViewMsg:@"Failed to load"];
                }
            });
    };
    
    [self.sessionManager sendRequest:request];
}

- (void)showInfoViewMsg:(NSString *)msg
{
    self.infoView.hidden = NO;
    self.infoBtn.hidden = YES;
    self.infoLabel.text = msg;
}

@end
