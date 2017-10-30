//
//  MyRidesViewController.m
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MyRidesViewController.h"
#import "MyRidesWaterfallView.h"
#import "RideListRequest.h"
#import "SetRideRequest.h"
 #import "DialogTip.h"
@interface MyRidesViewController ()<UIScrollViewRefreshDelegate,MyRidesWaterfallViewDelegate>

@property (weak, nonatomic) IBOutlet MyRidesWaterfallView *myRidesWaterfallView;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (nonatomic, strong) DialogTip *dialogTipView;
@end

@implementation MyRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.myRidesWaterfallView.delegates = self;
    
    [self.myRidesWaterfallView initPullRefresh:self pullDown:YES pullUp:NO];
    
    self.dialogTipView = [DialogTip dialogTip];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getMyRidesData];
}

/**
 *  下拉刷新
 */
- (void)pullDownRefresh {
    
    [self getMyRidesData];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)getMyRidesData
{
    [self showLoading];
    RideListRequest * request = [[RideListRequest alloc]init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<RideItemObject *> * _Nullable array, int totalCount) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            [self.myRidesWaterfallView finishPullDown:YES];
            if (success) {
                self.myRidesWaterfallView.items = array;
                [self.myRidesWaterfallView reloadData];
                
                if (self.myRidesWaterfallView.items.count == 0) {
                    [self showInfoViewMsg:NSLocalizedStringFromSelf(@"No Rides")];
                }
            }
            else
            {
                [self showInfoViewMsg:NSLocalizedStringFromSelf(@"Failed_Msg")];
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

- (void)myRidesWaterfallViewDidRiesId:(NSString *)riesId
{
    [self showLoading];
    
    SetRideRequest * request = [[SetRideRequest alloc]init];
    request.rideId = riesId;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                [self getMyRidesData];
            }
            else
            {
                [self.dialogTipView showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"SetRideMsg")];
            }
            
        });
    };
    
    [self.sessionManager sendRequest:request];
}

@end
