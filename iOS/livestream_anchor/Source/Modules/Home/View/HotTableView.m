//
//  HotTableView.m
//  livestream
//
//  Created by Max on 16/2/15.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import "HotTableView.h"

#import "HotTableViewCell.h"

#import "LSImageViewLoader.h"
#import "LSFileCacheManager.h"
#import "HomeVouchersManager.h"
#define IMAGE_COUNT 10
@interface HotTableView () <HotTableViewCellDelegate>

@end

@implementation HotTableView
@synthesize tableViewDelegate;
@synthesize items;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    self.canDeleteItem = NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)reloadData {
    [super reloadData];
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    switch (section) {
        case 0: {
            if (self.items.count > 0) {
                number = self.items.count;
            }
        }
        default:
            break;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return [HotTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;
    
    HotTableViewCell *cell = [HotTableViewCell getUITableViewCell:tableView];
    tableViewCell = cell;
    
    // 数据填充
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:indexPath.row];
    
    cell.tag = indexPath.row;
    // 房间名
    cell.labelRoomTitle.text = item.nickName;
    
    if (item.onlineStatus != ONLINE_STATUS_LIVE) {
        [cell.onlineIcon setImage:[UIImage imageNamed:@"home_offline_icon"]];
    }
    else
    {
        [cell.onlineIcon setImage:[UIImage imageNamed:@"home_online_icon"]];
    }
    
    cell.hotCellDelegate = self;
    switch (item.roomType) {
            // 没有直播间
        case HTTPROOMTYPE_NOLIVEROOM: {
            
            cell.viewPublicFreeBtn.hidden = YES;
            cell.viewPublicFeeBtn.hidden = YES;
            cell.normalPrivateCenterX.constant = 0;
            
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.bookPrivateBtn.hidden = NO;
                cell.normalPrivateBtn.hidden = YES;
                cell.vipPrivateBtn.hidden = YES;
            } else {
                cell.bookPrivateBtn.hidden = YES;
                cell.vipPrivateBtn.hidden = NO;
                cell.normalPrivateBtn.hidden = YES;
                if ([[HomeVouchersManager manager] isShowFreeLive:item.userId LiveRoomType:item.roomType]) {
                    //显示Free
                    [cell.vipPrivateBtn setImage:[UIImage imageNamed:@"Home_HotAndFollow_Btn_StartVipPrivateBroadcastAnimaition_Free"] forState:UIControlStateNormal];
                    cell.viewBtnTopDistance.constant = 2;
                }
                else
                {
                    //不显示Free
                    [cell.vipPrivateBtn setImage:[UIImage imageNamed:@"Home_HotAndFollow_Btn_StartVipPrivateBroadcastAnimaition"] forState:UIControlStateNormal];
                    cell.viewBtnTopDistance.constant = 9;
                }
            }
            
        } break;
            // 免费公开直播间
        case HTTPROOMTYPE_FREEPUBLICLIVEROOM: {
            
            //设置直播间类型显示图片
            cell.roomType.hidden = YES;
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = NO;
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
                cell.liveStatus.hidden = YES;
            } else {
                // 高级还是普通的私密直播间
                cell.viewPublicFreeBtn.hidden = NO;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = YES;
                cell.liveStatus.hidden = NO;
                NSMutableArray *animationPublicRTArray = [NSMutableArray array];
                for (int i = 1; i <= 3; i++) {
                    NSString *imageName = [NSString stringWithFormat:@"Home_HotAndFollow_ImageView_Live%d", i];
                    UIImage *image = [UIImage imageNamed:imageName];
                    [animationPublicRTArray addObject:image];
                }
                cell.liveStatus.animationImages = animationPublicRTArray;
                cell.liveStatus.animationRepeatCount = 0;
                cell.liveStatus.animationDuration = 0.6;
                [cell.liveStatus startAnimating];
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
            }
            
            
        } break;
            // 付费公开直播间
        case HTTPROOMTYPE_CHARGEPUBLICLIVEROOM: {
            //设置直播间类型显示图片
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = NO;
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
                cell.roomType.hidden = YES;
                cell.liveStatus.hidden = YES;
            } else {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = NO;
                cell.bookPrivateBtn.hidden = YES;
                cell.roomType.hidden = NO;
                cell.liveStatus.hidden = NO;
                NSMutableArray *animationVIPPublicRTArray = [NSMutableArray array];
                for (int i = 1; i <= 3; i++) {
                    NSString *imageName = [NSString stringWithFormat:@"Home_HotAndFollow_ImageView_Live%d", i];
                    UIImage *image = [UIImage imageNamed:imageName];
                    [animationVIPPublicRTArray addObject:image];
                }
                cell.liveStatus.animationImages = animationVIPPublicRTArray;
                cell.liveStatus.animationRepeatCount = 0;
                cell.liveStatus.animationDuration = 0.6;
                [cell.liveStatus startAnimating];
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
            }
            if ([[HomeVouchersManager manager] isShowFreeLive:item.userId LiveRoomType:item.roomType]) {
                //显示Free
                [cell.viewPublicFeeBtn setImage:[UIImage imageNamed:@"Home_HotAndFollow_Btn_ViewNow_Free"] forState:UIControlStateNormal];
                cell.viewBtnTopDistance.constant = 2;
            }
            else
            {
                //不显示Free
                [cell.viewPublicFeeBtn setImage:[UIImage imageNamed:@"Home_HotAndFollow_Btn_ViewNow"] forState:UIControlStateNormal];
                cell.viewBtnTopDistance.constant = 9;
            }
            
        } break;
            // 普通私密直播间
        case HTTPROOMTYPE_COMMONPRIVATELIVEROOM:
            // 豪华私密直播间
        case HTTPROOMTYPE_LUXURYPRIVATELIVEROOM: {
            cell.normalPrivateCenterX.constant = 0;
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = NO;
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
            } else {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = YES;
                cell.vipPrivateBtn.hidden = NO;
                cell.normalPrivateBtn.hidden = YES;
            }
            if ([[HomeVouchersManager manager] isShowFreeLive:item.userId LiveRoomType:item.roomType]) {
                //显示Free
                [cell.vipPrivateBtn setImage:[UIImage imageNamed:@"Home_HotAndFollow_Btn_StartVipPrivateBroadcastAnimaition_Free"] forState:UIControlStateNormal];
                cell.viewBtnTopDistance.constant = 2;
            }
            else
            {
                //不显示Free
                [cell.vipPrivateBtn setImage:[UIImage imageNamed:@"Home_HotAndFollow_Btn_StartVipPrivateBroadcastAnimaition"] forState:UIControlStateNormal];
                cell.viewBtnTopDistance.constant = 9;
            }
            
        } break;
            
        default:
            break;
    }
    
    // 头像
    
    cell.imageViewHeader.image = nil;
    [cell.imageViewLoader stop];
    [cell.imageViewLoader loadImageWithImageView:cell.imageViewHeader
                                         options:0
                                        imageUrl:item.roomPhotoUrl
                                placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"]];
    
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.items.count) {
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectItem:)]) {
            [self.tableViewDelegate tableView:self didSelectItem:[self.items objectAtIndex:indexPath.row]];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.canDeleteItem)
        return UITableViewCellEditingStyleDelete;
    else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            if (indexPath.row < self.items.count) {
                if ([self.tableViewDelegate respondsToSelector:@selector(tableView:willDeleteItem:)]) {
                    [self.tableViewDelegate tableView:self willDeleteItem:[self.items objectAtIndex:indexPath.row]];
                }
            }
            break;
        }
        default:
            break;
    }
}



#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.tableViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.tableViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark - cell的点击事件回调 (HotTableViewCell)
/** 预约私密直播间 */
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickBookPrivateBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didBookPrivateBroadcast:)]) {
        [self.tableViewDelegate tableView:self didBookPrivateBroadcast:cell.tag];
    }
}

/** 免费的公开直播间 */
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickViewPublicFreeBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPublicViewFreeBroadcast:)]) {
        [self.tableViewDelegate tableView:self didPublicViewFreeBroadcast:cell.tag];
    }
}

/** 付费的公开直播间 */
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickViewPublicFeeBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPublicViewVipFeeBroadcast:)]) {
        [self.tableViewDelegate tableView:self didPublicViewVipFeeBroadcast:cell.tag];
    }
}

/** 普通的私密直播间 */
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickNormalPrivateBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPrivateStartBroadcast:)]) {
        [self.tableViewDelegate tableView:self didPrivateStartBroadcast:cell.tag];
    }
}

/** 豪华的私密直播间 */
- (void)hotTableViewCell:(HotTableViewCell *)cell didClickVipPrivateBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didStartVipPrivteBroadcast:)]) {
        [self.tableViewDelegate tableView:self didStartVipPrivteBroadcast:cell.tag];
    }
}
@end

