//
//  FollowTableView.m
//  livestream
//
//  Created by test on 2017/9/8.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "FollowTableView.h"

#import "HotTableViewCell.h"
#import "FollowTableViewCell.h"

#import "ImageViewLoader.h"
#import "FileCacheManager.h"

@interface FollowTableView()<ImageViewLoaderDelegate,FollowTableViewCellDelegate>

@end

@implementation FollowTableView


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
    switch(section) {
        case 0: {
            if(self.items.count > 0) {
                number = self.items.count;
            }
        }
        default:break;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = self.frame.size.width;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;
    
    
    NSMutableArray *animationArray = [NSMutableArray array];
    for (int i = 1; i <= 6; i++) {
        NSString *imageName = [NSString stringWithFormat:@"Home_HotAndFollow_Btn_StartVipPrivateBroadcastAnimaition%d", i];
        UIImage *image = [UIImage imageNamed:imageName];
        [animationArray addObject:image];
    }
    
    FollowTableViewCell *cell = [FollowTableViewCell getUITableViewCell:tableView];
    tableViewCell = cell;
    cell.tag = indexPath.row;
    // 数据填充
    FollowItemObject *item = [self.items objectAtIndex:indexPath.row];
#warning test
    // 人数
    //    cell.labelViewers.text = item.roomId;
    
    // 房间名
        cell.labelRoomTitle.text = item.nickName;
    
    // 国家
    //    cell.labelCountry.text = item.country;
    // 人数
    //    cell.labelViewers.text = item.roomId;
    
    // 房间名
    cell.labelRoomTitle.text = item.userId;
    //    cell.labelRoomTitle.text = item.nickName;
    
    // 国家
    //    cell.labelCountry.text = item.country;
    
    cell.animationArray = animationArray;
    if (item.onlineStatus != ONLINE_STATUS_LIVE) {
        cell.onlineView.backgroundColor = [UIColor colorWithHexString:@"b5b5b5"];
    } else {
        cell.onlineView.backgroundColor = [UIColor colorWithHexString:@"8edb2b"];
    }
    cell.followCellDelegate = self;
    switch (item.roomType) {
            // 没有直播间
        case HTTPROOMTYPE_NOLIVEROOM: {
            [cell.roomType setImage:nil];
            cell.viewPublicFreeBtn.hidden = YES;
            cell.viewPublicFeeBtn.hidden = YES;
            
            cell.vipPrivateCenterX.constant = 0;
            cell.normalPrivateCenterX.constant = 0;
            
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.bookPrivateBtn.hidden = NO;
                cell.normalPrivateBtn.hidden = YES;
                cell.vipPrivateBtn.hidden = YES;
            }else {
                cell.bookPrivateBtn.hidden = YES;
                switch (item.anchorType) {
                    case ANCHORLEVELTYPE_SILVER: {
                        // 普通
                        cell.normalPrivateBtn.hidden = NO;
                        cell.vipPrivateBtn.hidden = YES;
                    } break;
                    case ANCHORLEVELTYPE_GOLD: {
                        //                        //高级
                        cell.vipPrivateBtn.hidden = NO;
                        cell.normalPrivateBtn.hidden = YES;
                    }
                        
                    default:
                        break;
                }
            }
        } break;
            // 免费公开直播间
        case HTTPROOMTYPE_FREEPUBLICLIVEROOM: {
            [cell.roomType setImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_RoomTypePublicLive"]];
            cell.vipPrivateCenterX.constant = -80;
            cell.normalPrivateCenterX.constant = -80;
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                // 不在线
                [cell.roomType setImage:nil];
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = NO;
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
            } else {
                // 高级还是普通的私密直播间
                cell.viewPublicFreeBtn.hidden = NO;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = YES;
                
                
                switch (item.anchorType) {
                    case ANCHORLEVELTYPE_SILVER: {
                        // 普通
                        cell.normalPrivateBtn.hidden = NO;
                        cell.vipPrivateBtn.hidden = YES;
                        
                    } break;
                    case ANCHORLEVELTYPE_GOLD: {
                        //高级
                        cell.vipPrivateBtn.hidden = NO;
                        cell.normalPrivateBtn.hidden = YES;
               
                    }
                        
                    default:
                        break;
                }
            }
            
        } break;
            // 付费公开直播间
        case HTTPROOMTYPE_CHARGEPUBLICLIVEROOM: {
            [cell.roomType setImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_RoomTypePublicLive"]];
            cell.vipPrivateCenterX.constant = -80;
            cell.normalPrivateCenterX.constant = -80;
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                [cell.roomType setImage:nil];
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = NO;
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
            } else {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = NO;
                cell.bookPrivateBtn.hidden = YES;
                switch (item.anchorType) {
                    case ANCHORLEVELTYPE_SILVER: {
                        // 普通
                        cell.normalPrivateBtn.hidden = NO;
                        cell.vipPrivateBtn.hidden = YES;
                    } break;
                    case ANCHORLEVELTYPE_GOLD: {
                         //高级
                        cell.vipPrivateBtn.hidden = NO;
                        cell.normalPrivateBtn.hidden = YES;
                    }
                        
                    default:
                        break;
                }
            }
            
        } break;
            // 普通私密直播间
        case HTTPROOMTYPE_COMMONPRIVATELIVEROOM:
            // 豪华私密直播间
        case HTTPROOMTYPE_LUXURYPRIVATELIVEROOM: {
            cell.vipPrivateCenterX.constant = 0;
            cell.normalPrivateCenterX.constant = 0;
            [cell.roomType setImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_RoomTypePrivateLive"]];
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                [cell.roomType setImage:nil];
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = NO;
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
            } else {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = YES;
                switch (item.anchorType) {
                    case ANCHORLEVELTYPE_SILVER: {
                        // 普通
                        cell.vipPrivateBtn.hidden = YES;
                        cell.normalPrivateBtn.hidden = NO;
                    } break;
                    case ANCHORLEVELTYPE_GOLD: {
                        cell.vipPrivateBtn.hidden = NO;
                        cell.normalPrivateBtn.hidden = YES;
                    }
                        
                    default:
                        break;
                }
            }
            
        } break;
            
        default:
            break;
    }
    
    if (item.interest.count > 0) {
        
        if (item.interest.count == 1) {
            NSString *interest1Name = [NSString stringWithFormat:@"%@", item.interest[0]];
            cell.interest3.image = [UIImage imageNamed:interest1Name];
            cell.interest1.hidden = YES;
            cell.interest2.hidden = YES;
            cell.interest3.hidden = NO;
        } else if (item.interest.count == 2) {
            NSString *interest3Name = [NSString stringWithFormat:@"%@", item.interest[0]];
            NSString *interest2Name = [NSString stringWithFormat:@"%@", item.interest[1]];
            cell.interest3.image = [UIImage imageNamed:interest3Name];
            cell.interest2.image = [UIImage imageNamed:interest2Name];
            cell.interest1.hidden = YES;
            cell.interest2.hidden = NO;
            cell.interest3.hidden = NO;
        } else {
            NSString *interest3Name = [NSString stringWithFormat:@"%@", item.interest[0]];
            NSString *interest2Name = [NSString stringWithFormat:@"%@", item.interest[1]];
            NSString *interest1Name = [NSString stringWithFormat:@"%@", item.interest[2]];
            cell.interest1.image = [UIImage imageNamed:interest1Name];
            cell.interest2.image = [UIImage imageNamed:interest2Name];
            cell.interest3.image = [UIImage imageNamed:interest3Name];
            
            cell.interest1.hidden = NO;
            cell.interest2.hidden = NO;
            cell.interest3.hidden = NO;
        }
        
    } else {
        cell.interest1.hidden = YES;
        cell.interest2.hidden = YES;
        cell.interest3.hidden = YES;
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
        if([self.tableViewDelegate respondsToSelector:@selector(followTableView:didSelectItem:)]) {
            [self.tableViewDelegate followTableView:self didSelectItem:[self.items objectAtIndex:indexPath.row]];
        }
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.canDeleteItem)
        return UITableViewCellEditingStyleDelete;
    else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            if (indexPath.row < self.items.count) {
                if([self.tableViewDelegate respondsToSelector:@selector(followTableView:willDeleteItem:)]) {
                    [self.tableViewDelegate followTableView:self willDeleteItem:[self.items objectAtIndex:indexPath.row]];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
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
- (void)followTableViewCell:(FollowTableViewCell *)cell didClickBookPrivateBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didBookPrivateBroadcast:)]) {
        [self.tableViewDelegate tableView:self didBookPrivateBroadcast:cell.tag];
    }
}

/** 免费的公开直播间 */
- (void)followTableViewCell:(FollowTableViewCell *)cell didClickViewPublicFreeBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPublicViewFreeBroadcast:)]) {
        [self.tableViewDelegate tableView:self didPublicViewFreeBroadcast:cell.tag];
    }
}

/** 付费的公开直播间 */
- (void)followTableViewCell:(FollowTableViewCell *)cell didClickViewPublicFeeBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPublicViewVipFeeBroadcast:)]) {
        [self.tableViewDelegate tableView:self didPublicViewVipFeeBroadcast:cell.tag];
    }
}

/** 普通的私密直播间 */
- (void)followTableViewCell:(FollowTableViewCell *)cell didClickNormalPrivateBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPrivateStartBroadcast:)]) {
        [self.tableViewDelegate tableView:self didPrivateStartBroadcast:cell.tag];
    }
}

/** 豪华的私密直播间 */
- (void)followTableViewCell:(FollowTableViewCell *)cell didClickVipPrivateBtn:(UIButton *)sender {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didStartVipPrivteBroadcast:)]) {
        [self.tableViewDelegate tableView:self didStartVipPrivteBroadcast:cell.tag];
    }
}
//- (void)followTableViewCell:(FollowTableViewCell *)cell didClickBookPrivateBtn:(UIButton *)sender;
//- (void)followTableViewCell:(FollowTableViewCell *)cell didClickViewPublicFreeBtn:(UIButton *)sender;
//- (void)followTableViewCell:(FollowTableViewCell *)cell didClickViewPublicFeeBtn:(UIButton *)sender;
//- (void)followTableViewCell:(FollowTableViewCell *)cell didClickNormalPrivateBtn:(UIButton *)sender;
//- (void)followTableViewCell:(FollowTableViewCell *)cell didClickVipPrivateBtn:(UIButton *)sender;

@end


