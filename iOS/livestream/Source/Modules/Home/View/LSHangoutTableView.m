//
//  LSHangoutTableView.m
//  livestream
//
//  Created by Calvin on 2019/1/16.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSHangoutTableView.h"
#import "HangoutListCell.h"
#import "LiveRoomInfoItemObject.h"


@interface LSHangoutTableView()<HangoutListCellDelegate>

@end


@implementation LSHangoutTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 476;
    LSHangoutListItemObject *item = [self.items objectAtIndex:indexPath.row];
    if (item.invitationMsg.length > 0) {
      height = [HangoutListCell cellHeight];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;
    HangoutListCell *cell = [HangoutListCell getUITableViewCell:tableView];
    cell.hangoutDelegate = self;
    
    tableViewCell = cell;
    
    // 数据填充
    LSHangoutListItemObject *item = [self.items objectAtIndex:indexPath.row];
//    [cell setScrollLabelViewText:[NSString stringWithFormat:@"%@'s circle has %d friends",item.nickName,(int)item.friendsInfoList.count]];
    
    cell.anchorName.text = item.nickName;
    [cell loadFriendData:item.friendsInfoList];
    [cell loadInviteMsg:item.invitationMsg];
    // 头像
    cell.imageViewHeader.image = nil;
    [cell.imageViewLoader stop];
    [cell.imageViewLoader loadImageWithImageView:cell.imageViewHeader
                                         options:0
                                        imageUrl:item.coverImg
                                placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"]];
    
    cell.hangoutButton.tag = indexPath.row + 88;
    cell.tag = indexPath.row + 888;
    
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didShowItem:)]) {
//        [self.tableViewDelegate tableView:self didShowItem:indexPath];
//    }
}

- (void)hangoutListCellDidHangout:(NSInteger)row {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didClickHangout:)]) {
        NSIndexPath *currentLadyIndex = [NSIndexPath indexPathForRow:row inSection:0];
        NSInteger row = currentLadyIndex.row;
        LSHangoutListItemObject *item = [self.items objectAtIndex:row];
        
        [self.tableViewDelegate tableView:self didClickHangout:item];
    }
}

- (void)hangoutListCellDidAchorPhoto:(NSInteger)row {
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didShowItem:)]) {
        NSIndexPath *currentLadyIndex = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableViewDelegate tableView:self didShowItem:currentLadyIndex];
    }
}

- (void)hangoutListCell:(HangoutListCell *)cell didClickAchorFriendPhoto:(NSInteger)row {
    if([self.tableViewDelegate respondsToSelector:@selector(tableView:didClickHangoutFriendCardMsg:)]){
        LSHangoutListItemObject *listItem = [self.items objectAtIndex:cell.tag - 888];
        LSFriendsInfoItemObject *item = [listItem.friendsInfoList objectAtIndex:row];
        [self.tableViewDelegate tableView:self didClickHangoutFriendCardMsg:item];
    }
}
@end
