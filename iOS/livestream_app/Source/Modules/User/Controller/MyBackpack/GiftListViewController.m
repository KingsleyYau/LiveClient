//
//  GiftListViewController.m
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftListViewController.h"
#import "GiftListRequest.h"
#import "DialogTip.h"
@interface GiftListViewController ()<UIScrollViewRefreshDelegate>

@property (weak, nonatomic) IBOutlet GiftListWaterfallView *giftListWaterfallView;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, assign) BOOL isRequstData;
@property (nonatomic, strong) NSTimer * timer;
@end

@implementation GiftListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.sessionManager = [LSSessionRequestManager manager];
    
    [self.giftListWaterfallView initPullRefresh:self pullDown:YES pullUp:NO];
}


- (void)dealloc {
    [self.giftListWaterfallView unInitPullRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isRequstData = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
}

- (void)loadData
{
    [self.timer invalidate];
    self.timer = nil;
    if (self.isRequstData) {
        [self showLoading];
        [self getGiftList];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isRequstData = NO;
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
    self.infoView.hidden = YES;
    //self.giftListWaterfallView.hidden = NO;
    GiftListRequest * request = [[GiftListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<BackGiftItemObject *> * _Nullable array, int totalCount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                [self.giftListWaterfallView finishPullDown:YES];
                [self.mainVC getunreadCount];
                
                self.giftListWaterfallView.items = array;
                
                if (success) {

                    if (self.giftListWaterfallView.items.count == 0) {
                          [self showInfoViewMsg:NSLocalizedStringFromSelf(@"No Gifts") hiddenBtn:YES];
                    }
                }
                else
                {
                    if (array.count == 0) {
                      [self showInfoViewMsg:NSLocalizedStringFromSelf(@"Failed to load") hiddenBtn:NO];
                    }
                    else
                    {
                        [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
                    }
                }
                [self.giftListWaterfallView reloadData];

            });
    };
    
    [self.sessionManager sendRequest:request];
}

- (void)showInfoViewMsg:(NSString *)msg hiddenBtn:(BOOL)hidden
{
    self.infoView.hidden = NO;
    self.infoBtn.layer.cornerRadius = 5;
    self.infoBtn.layer.masksToBounds = YES;
    self.infoLabel.text = msg;
    self.infoBtn.hidden = hidden;
    //self.giftListWaterfallView.hidden = YES;
}

- (IBAction)reloadBtnDid:(UIButton *)sender {
    [self showLoading];
    [self getGiftList];
}

@end
