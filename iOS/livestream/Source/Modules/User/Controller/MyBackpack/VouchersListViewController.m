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
#import "DialogTip.h"
@interface VouchersListViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewRefreshDelegate>

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * array;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@property (weak, nonatomic) IBOutlet UIImageView *noDataIcon;
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
    [self showLoading];
    [self getVoucherListRequest];
}

#pragma mark 重新加载
- (IBAction)reloadBtnDid:(UIButton *)sender {
    
    [self showLoading];
    [self getVoucherListRequest];
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
    //self.tableView.hidden = NO;
    VoucherListRequest * request = [[VoucherListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<VoucherItemObject *> * _Nullable array, int totalCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            [self.tableView finishPullDown:YES];
            [self.mainVC getunreadCount];
            
            self.array = array;
            if (success) {
                
                if (self.array.count == 0) {
                    [self showInfoViewMsg:NSLocalizedStringFromSelf(@"No Vouchers") hiddenBtn:YES];
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
            [self.tableView reloadData];
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
    //self.tableView.hidden = YES;
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
        
        
        if (!cell.imageViewLoader) {
            cell.imageViewLoader = [LSImageViewLoader loader];
        }
        
        [cell.imageViewLoader loadImageWithImageView:cell.minImage options:0 imageUrl:obj.photoUrlMobile placeholderImage:nil];
        
        cell.timeLabel.text = [NSString stringWithFormat:@"%@:%@ - %@",NSLocalizedString(@"Vaild_Time", @"Vaild_Time"),[cell getTime:obj.startValidDate],[cell getTime:obj.expDate]];
        
        cell.unreadView.hidden = obj.read;
        
        cell.titleLabel.text = obj.desc;
        
        // 指定主播
        if (obj.anchorType == ANCHORTYPE_APPOINTANCHOR)
        {
            cell.oneLadyView.hidden = NO;
            cell.allLadyView.hidden = YES;
            
            cell.nameLabel.text = obj.anchorNcikName;
            
            [[LSImageViewLoader loader] refreshCachedImage:cell.ladyHeadView options:SDWebImageRefreshCached imageUrl:obj.anchorPhotoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
            
            cell.ladyLabel.text = NSLocalizedStringFromSelf(@"Only_broadcaster");
            // 公开
            if (obj.useRoomType == USEROOMTYPE_PUBLIC)
            {
                cell.onlyLadyLabel.text = NSLocalizedStringFromSelf(@"Only_Public");
            }
            //私密
            else if (obj.useRoomType == USEROOMTYPE_PRIVATE)
            {
                cell.onlyLadyLabel.text = NSLocalizedStringFromSelf(@"Only_Private");
            }
            else
            {
                cell.onlyLadyLabel.text = NSLocalizedStringFromSelf(@"No limit sessions");
            }
        }
        // 不限和没看过直播的主播
        else
        {
            cell.oneLadyView.hidden = YES;
            cell.allLadyView.hidden = NO;
            
            //没看过直播的主播
            if (obj.anchorType == ANCHORTYPE_NOSEEANCHOR) {
                cell.ladyTypeLabel.text = NSLocalizedStringFromSelf(@"New broadcasters");
            }
            else
            {
                cell.ladyTypeLabel.text =NSLocalizedStringFromSelf(@"No_limit");
            }
            
            // 公开
            if (obj.useRoomType == USEROOMTYPE_PUBLIC)
            {
                cell.liveTypeLabel.text = NSLocalizedStringFromSelf(@"Only_Public");
            }
            //私密
            else if (obj.useRoomType == USEROOMTYPE_PRIVATE)
            {
                cell.liveTypeLabel.text = NSLocalizedStringFromSelf(@"Only_Private");
            }
            else
            {
                cell.liveTypeLabel.text = NSLocalizedStringFromSelf(@"No limit sessions");
            }
        }
    }
    
    return result;
}

@end

