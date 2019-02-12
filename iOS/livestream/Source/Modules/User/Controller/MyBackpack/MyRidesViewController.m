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
@property (weak, nonatomic) IBOutlet UIImageView *noDataIcon;
@end

@implementation MyRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.myRidesWaterfallView.delegates = self;
    
    [self.myRidesWaterfallView initPullRefresh:self pullDown:YES pullUp:NO];
    
    self.dialogTipView = [DialogTip dialogTip];
}

- (void)dealloc {
    [self.myRidesWaterfallView unInitPullRefresh];
    NSLog(@"MyRidesViewController dealloc");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showLoading];
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
    self.infoView.hidden = YES;
    //self.myRidesWaterfallView.hidden = NO;
    RideListRequest * request = [[RideListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<RideItemObject *> * _Nullable array, int totalCount) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            [self.myRidesWaterfallView finishPullDown:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"MyBackPackGetUnreadCount" object:nil];
            self.myRidesWaterfallView.items = array;
            if (success) {

                if (self.myRidesWaterfallView.items.count == 0) {
                    [self showInfoViewMsg:NSLocalizedStringFromSelf(@"No Rides") hiddenBtn:YES];
                }
            }
            else
            {
                if (array.count == 0) {
                    [self showInfoViewMsg:NSLocalizedStringFromSelf(@"Failed to load") hiddenBtn:NO];
                }
                else
                {
                    [self.dialogTipView showDialogTip:self.view tipText:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
                }
            }
            [self.myRidesWaterfallView reloadData];
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
    // 是否没有数据
    if (hidden) {
        self.noDataIcon.image = [UIImage imageNamed:@"Common_NoDataIcon"];
    }else {
        self.noDataIcon.image = [UIImage imageNamed:@"Home_Hot&follow_fail"];
    }
    //self.myRidesWaterfallView.hidden = YES;
}

- (IBAction)reloadBtnDid:(UIButton *)sender {
    [self showLoading];
    [self getMyRidesData];
}

- (void)myRidesWaterfallViewDidRiesId:(NSString *)riesId
{
    [self showLoading];
    
    SetRideRequest * request = [[SetRideRequest alloc]init];
    request.rideId = riesId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
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
