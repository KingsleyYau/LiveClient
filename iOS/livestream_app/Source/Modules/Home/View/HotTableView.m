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
    return 1.5;
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
    CGFloat height = 0.0;
    height = self.frame.size.width;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;

    NSMutableArray *animationArray = [NSMutableArray array];
    for (int i = 1; i <= 11; i++) {
        NSString *imageName = [NSString stringWithFormat:@"Home_HotAndFollow_Btn_StartVipPrivateBroadcastAnimaition%d", i];
        UIImage *image = [UIImage imageNamed:imageName];
        [animationArray addObject:image];
    }
    
    
    
    HotTableViewCell *cell = [HotTableViewCell getUITableViewCell:tableView];
    tableViewCell = cell;

    // 数据填充
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:indexPath.row];

    cell.tag = indexPath.row;
    //    cell.leftBtn.tag = indexPath.row;
    //    cell.midBtn.tag = indexPath.row;
    //    cell.rightBtn.tag = indexPath.row;
    // 人数
    //    cell.labelViewers.text = item.roomId;

    // 房间名
    cell.labelRoomTitle.text = item.nickName;

    // 国家
    //cell.labelCountry.text = item.country;

    cell.animationArray = animationArray;
    
    // 左上角主播状态默认图（离线）
    [cell.roomType setImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Offline_RoomType"]];

    cell.hotCellDelegate = self;
    switch (item.roomType) {
            // 没有直播间
        case HTTPROOMTYPE_NOLIVEROOM: {
            
            cell.viewPublicFreeBtn.hidden = YES;
            cell.viewPublicFeeBtn.hidden = YES;
            
            cell.vipPrivateCenterX.constant = 0;
            cell.normalPrivateCenterX.constant = 0;
            
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.bookPrivateBtn.hidden = NO;
                cell.normalPrivateBtn.hidden = YES;
                cell.vipPrivateBtn.hidden = YES;
            } else {
                cell.bookPrivateBtn.hidden = YES;
                
                //**************👇需要修改内容👇*****************//
                //主播在线且没有直播间，显示的图片
                [cell.roomType setImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Online_RoomType"]];
                //**************👆需要修改内容👆*****************//
                
                // Modify by Max, 不用显示普通私密
                //                switch (item.anchorType) {
                //                    case ANCHORLEVELTYPE_SILVER: {
                //                        // 普通
                //                        cell.normalPrivateBtn.hidden = NO;
                //                        cell.vipPrivateBtn.hidden = YES;
                //                    } break;
                //                    case ANCHORLEVELTYPE_GOLD: {
                //                        // 高级
                //                        cell.vipPrivateBtn.hidden = NO;
                //                        cell.normalPrivateBtn.hidden = YES;
                //                    }
                //                    default:
                //                        break;
                //                }
                cell.vipPrivateBtn.hidden = NO;
                cell.normalPrivateBtn.hidden = YES;
            }
            
        } break;
            // 免费公开直播间
        case HTTPROOMTYPE_FREEPUBLICLIVEROOM: {
            
            //设置直播间类型显示图片
            cell.vipPrivateCenterX.constant = DESGIN_TRANSFORM_3X(-90);
            cell.normalPrivateCenterX.constant = DESGIN_TRANSFORM_3X(-90);
            cell.vipPublicCenterX.constant = DESGIN_TRANSFORM_3X(90);
            cell.normalPublicCenterX.constant = DESGIN_TRANSFORM_3X(90);
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = NO;
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
            } else {
                //**************👇需要修改内容👇*****************//
                // 高级还是普通的私密直播间
                cell.viewPublicFreeBtn.hidden = NO;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = YES;
                //主播在线且免费公开直播,显示动态红色摄像机public
                NSMutableArray *animationPublicRTArray = [NSMutableArray array];
                for (int i = 1; i <= 12; i++) {
                    NSString *imageName = [NSString stringWithFormat:@"Home_HotAndFollow_ImageView_Public_RoomType%d", i];
                    UIImage *image = [UIImage imageNamed:imageName];
                    [animationPublicRTArray addObject:image];
                }
                cell.roomType.animationImages = animationPublicRTArray;
                cell.roomType.animationRepeatCount = 0;
                cell.roomType.animationDuration = 1.2;
                [cell.roomType startAnimating];
                //**************👆需要修改内容👆*****************//
                
                // Modify by Max, 不用显示普通私密
                //                switch (item.anchorType) {
                //                    case ANCHORLEVELTYPE_SILVER: {
                //                        // 普通
                //                        cell.normalPrivateBtn.hidden = NO;
                //                        cell.vipPrivateBtn.hidden = YES;
                //
                //                    } break;
                //                    case ANCHORLEVELTYPE_GOLD: {
                //                        cell.vipPrivateBtn.hidden = NO;
                //                        cell.normalPrivateBtn.hidden = YES;
                //                        //高级
                //                    }
                //
                //                    default:
                //                        break;
                //                }
                cell.vipPrivateBtn.hidden = NO;
                cell.normalPrivateBtn.hidden = YES;
            }
            
        } break;
            // 付费公开直播间
        case HTTPROOMTYPE_CHARGEPUBLICLIVEROOM: {
            //设置直播间类型显示图片
            cell.vipPrivateCenterX.constant = DESGIN_TRANSFORM_3X(-90);
            cell.normalPrivateCenterX.constant = DESGIN_TRANSFORM_3X(-90);
            cell.vipPublicCenterX.constant = DESGIN_TRANSFORM_3X(90);
            cell.normalPublicCenterX.constant = DESGIN_TRANSFORM_3X(90);
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = NO;
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
            } else {
                //**************👇需要修改内容👇*****************//
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = NO;
                cell.bookPrivateBtn.hidden = YES;
                //主播在线且免费公开直播,显示动态红色摄像机public有vip标识
                NSMutableArray *animationVIPPublicRTArray = [NSMutableArray array];
                for (int i = 1; i <= 12; i++) {
                    NSString *imageName = [NSString stringWithFormat:@"Home_HotAndFollow_ImageView_VIPPublic_RoomType%d", i];
                    UIImage *image = [UIImage imageNamed:imageName];
                    [animationVIPPublicRTArray addObject:image];
                }
                cell.roomType.animationImages = animationVIPPublicRTArray;
                cell.roomType.animationRepeatCount = 0;
                cell.roomType.animationDuration = 1.2;
                [cell.roomType startAnimating];
                //**************👆需要修改内容👆*****************//
                
                // Modify by Max, 不用显示普通私密
                //                switch (item.anchorType) {
                //                    case ANCHORLEVELTYPE_SILVER: {
                //                        // 普通
                //                        cell.normalPrivateBtn.hidden = NO;
                //                        cell.vipPrivateBtn.hidden = YES;
                //                    } break;
                //                    case ANCHORLEVELTYPE_GOLD: {
                //                        //                        //高级
                //                        cell.vipPrivateBtn.hidden = NO;
                //                        cell.normalPrivateBtn.hidden = YES;
                //                    }
                //
                //                    default:
                //                        break;
                //                }
                cell.vipPrivateBtn.hidden = NO;
                cell.normalPrivateBtn.hidden = YES;
            }
            
        } break;
            // 普通私密直播间
        case HTTPROOMTYPE_COMMONPRIVATELIVEROOM:
            // 豪华私密直播间
        case HTTPROOMTYPE_LUXURYPRIVATELIVEROOM: {
            cell.vipPrivateCenterX.constant = 0;
            cell.normalPrivateCenterX.constant = 0;
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                //[cell.roomType setImage:nil];
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = NO;
                cell.vipPrivateBtn.hidden = YES;
                cell.normalPrivateBtn.hidden = YES;
            } else {
                cell.viewPublicFreeBtn.hidden = YES;
                cell.viewPublicFeeBtn.hidden = YES;
                cell.bookPrivateBtn.hidden = YES;
                [cell.roomType setImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Online_RoomType"]];
                
                // Modify by Max, 不用显示普通私密
                //                switch (item.anchorType) {
                //                    case ANCHORLEVELTYPE_SILVER: {
                //                        // 普通
                //                        cell.vipPrivateBtn.hidden = YES;
                //                        cell.normalPrivateBtn.hidden = NO;
                //                    } break;
                //                    case ANCHORLEVELTYPE_GOLD: {
                //                        cell.vipPrivateBtn.hidden = NO;
                //                        cell.normalPrivateBtn.hidden = YES;
                //                    }
                //
                //                    default:
                //                        break;
                //                }
                cell.vipPrivateBtn.hidden = NO;
                cell.normalPrivateBtn.hidden = YES;
            }
            
        } break;
            
        default:
            break;
    }

    if (item.interest.count > 0) {

        if (item.interest.count == 1) {
            NSString *interest1Name = [NSString stringWithFormat:@"interest_%@", item.interest[0]];
            cell.interest3.image = [UIImage imageNamed:interest1Name];
            cell.interest1.hidden = YES;
            cell.interest2.hidden = YES;
            cell.interest3.hidden = NO;
        } else if (item.interest.count == 2) {
            NSString *interest3Name = [NSString stringWithFormat:@"interest_%@", item.interest[0]];
            NSString *interest2Name = [NSString stringWithFormat:@"interest_%@", item.interest[1]];
            cell.interest3.image = [UIImage imageNamed:interest3Name];
            cell.interest2.image = [UIImage imageNamed:interest2Name];
            cell.interest1.hidden = YES;
            cell.interest2.hidden = NO;
            cell.interest3.hidden = NO;
        } else {
            NSString *interest3Name = [NSString stringWithFormat:@"interest_%@", item.interest[0]];
            NSString *interest2Name = [NSString stringWithFormat:@"interest_%@", item.interest[1]];
            NSString *interest1Name = [NSString stringWithFormat:@"interest_%@", item.interest[2]];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1.5)];
    headerSection.backgroundColor = [UIColor clearColor];
    return headerSection;
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

//#pragma mark - 免费公开直播间
//- (void)publicStartPrivteBroadcast:(UIButton *)btn {
//    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPublicStartPrivteBroadcast:)]) {
//        NSInteger index = btn.tag;
//        [self.tableViewDelegate tableView:self didPublicStartPrivteBroadcast:index];
//    }
//}
//
//- (void)publicViewBroadcast:(UIButton *)btn {
//    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPublicViewBroadcast:)]) {
//        NSInteger index = btn.tag;
//        [self.tableViewDelegate tableView:self didPublicViewBroadcast:index];
//    }
//}
//
//#pragma mark - 付费公开直播间
//
//- (void)publicStartVipPrivteBroadcast:(UIButton *)btn {
//    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPublicStartVipPrivteBroadcast:)]) {
//        NSInteger index = btn.tag;
//        [self.tableViewDelegate tableView:self didPublicStartVipPrivteBroadcast:index];
//    }
//}
//
//- (void)publicViewVipBroadcast:(UIButton *)btn {
//    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPublicViewVipBroadcast:)]) {
//        NSInteger index = btn.tag;
//        [self.tableViewDelegate tableView:self didPublicViewVipBroadcast:index];
//    }
//}
//
//#pragma mark - 普通私密直播间和豪华
//
//- (void)privateStartBroadcast:(UIButton *)btn {
//    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didPrivateStartBroadcast:)]) {
//        NSInteger index = btn.tag;
//        [self.tableViewDelegate tableView:self didPrivateStartBroadcast:index];
//    }
//}
//
//#pragma mark - 离线状态
//- (void)bookPrivateBroadcast:(UIButton *)btn {
//
//    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didBookPrivateBroadcast:)]) {
//        NSInteger index = btn.tag;
//        [self.tableViewDelegate tableView:self didBookPrivateBroadcast:index];
//    }
//
//}
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
