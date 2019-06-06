//
//  DoorTableView.m
//  livestream
//
//  Created by Max on 16/2/15.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import "DoorTableView.h"
#import "DoorTableViewCell.h"

#import "LSImageViewLoader.h"
#import "LSFileCacheManager.h"

@interface DoorTableView () <DoorTableViewCellDelegate>

@end

@implementation DoorTableView
@synthesize tableViewDelegate;
@synthesize items;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
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
    return 0.01;
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
    return [DoorTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoorTableViewCell *cell = [DoorTableViewCell getUITableViewCell:tableView];
    [cell reset];

    // 数据填充
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:indexPath.row];
    // 房间名
    cell.labelRoomTitle.text = [NSString stringWithFormat:@"%@(%@)", item.nickName, item.userId];

    if (item.onlineStatus == ONLINE_STATUS_LIVE) {
        if (item.roomType != HTTPROOMTYPE_NOLIVEROOM) {
            cell.onlineImageView.hidden = NO;
        }

    } else {
        // 不在线
    }

    // 头像
    [cell.imageViewLoader stop];
    [cell.imageViewLoader loadHDListImageWithImageView:cell.imageViewHeader
                                               options:0
                                              imageUrl:item.roomPhotoUrl
                                      placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"]
                                         finishHandler:nil];

    return cell;
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
@end

