//
//  VouchersListViewController.m
//  livestream
//
//  Created by Calvin on 17/10/13.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "VouchersListViewController.h"
#import "VouchersCell.h"
#import "VoucherListRequest.h"
@interface VouchersListViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewRefreshDelegate>

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * array;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@end

@implementation VouchersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.array = [NSArray array];
    self.sessionManager = [LSSessionRequestManager manager];
    self.infoBtn.layer.cornerRadius = 5;
    self.infoBtn.layer.masksToBounds = YES;
    
    [self.tableView setTableFooterView:[UIView new]];
    
    [self.tableView initPullRefresh:self pullDown:YES pullUp:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getVoucherListRequest];
}

#pragma mark 重新加载
- (IBAction)reloadBtnDid:(UIButton *)sender {
    
    [self pullDownRefresh];
}

/**
 *  下拉刷新
 */
- (void)pullDownRefresh {
    
    [self getVoucherListRequest];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

#pragma mark 获取试聊券
- (void)getVoucherListRequest
{
    self.infoView.hidden = YES;
    [self showLoading];
    VoucherListRequest * request = [[VoucherListRequest alloc]init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<VoucherItemObject *> * _Nullable array, int totalCount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                [self.tableView finishPullDown:YES];
                if (success) {
                    self.array = array;
                    [self.tableView reloadData];
                    
                    if (self.array.count == 0) {
                       [self showInfoViewMsg:@"No Vouchers"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VouchersCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    VouchersCell *result = nil;
    VouchersCell * cell = [VouchersCell getUITableViewCell:tableView];
    result = cell;
    
    if (self.array.count > 0) {
        VoucherItemObject * obj = [self.array objectAtIndex:indexPath.row];
        
        [cell.imageViewLoader stop];
        if (!cell.imageViewLoader) {
            cell.imageViewLoader = [LSImageViewLoader loader];
        }
        [cell.imageViewLoader loadImageWithImageView:cell.minImage options:0 imageUrl:obj.photoUrl placeholderImage:nil];
        
        cell.timeLabel.text = [NSString stringWithFormat:@"Use by:%@",[cell getTime:obj.expDate]];
        
        cell.unreadView.hidden = obj.read;
        
        if (obj.anchorType == ANCHORTYPE_APPOINTANCHOR)
        {
            cell.oneLadyView.hidden = NO;
            cell.allLadyView.hidden = YES;
            
            [cell.imageViewLoader loadImageWithImageView:cell.ladyHeadView options:0 imageUrl:obj.anchorPhotoUrl placeholderImage:[UIImage imageNamed:@"Live_PreLive_Img_Head_Default"]];
        }
        else
        {
            cell.oneLadyView.hidden = YES;
            cell.allLadyView.hidden = NO;
        }
    }
    
    return result;
}

@end
