//
//  LSContactListTableView.m
//  livestream
//
//  Created by test on 2018/11/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "QNContactListTableView.h"


@implementation QNContactListTableView

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
    [self registerNib:[UINib nibWithNibName:@"QNContactListTableViewCell" bundle:[LiveBundle mainBundle]] forCellReuseIdentifier:[QNContactListTableViewCell cellIdentifier]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
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
                self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                number = self.items.count;
                
            } else {
                self.separatorStyle = UITableViewCellSeparatorStyleNone;
                number = 0;
                
            }
        }
        default:break;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = [QNContactListTableViewCell cellHeight];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    
    
    QNContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[QNContactListTableViewCell cellIdentifier]];
    result = cell;
    // 数据填充
    LSLadyRecentContactObject *item = [self.items objectAtIndex:indexPath.row];
    cell.ladyName.text = item.userName;
    [cell.imageViewLoader stop];
    cell.imageViewLoader = nil;
    // 创建新的
    cell.imageViewLoader = [LSImageViewLoader loader];
    // 加载
    [cell.imageViewLoader refreshCachedImage:cell.ladyImage options:SDWebImageRefreshCached imageUrl:item.photoURL placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    if (item.unreadCount > 0) {
        cell.unreadCountIcon.text = [NSString stringWithFormat:@"%ld",(long)item.unreadCount];
        if (item.unreadCount >= 10) {
            cell.unreadCountIconWidth.constant = 20;
        }else {
            cell.unreadCountIconWidth.constant = 13;
        }
        if (item.unreadCount > 99) {
            cell.unreadCountIcon.text = @"99+";
            cell.unreadCountIconWidth.constant = 28;
        }

        cell.unreadCountIcon.hidden = NO;
    }else {
        cell.unreadCountIcon.text = @"";
        cell.unreadCountIcon.hidden = YES;
    }

    // 最后一条消息
    if( item.lastInviteMessage != nil && item.lastInviteMessage.length > 0 ) {
        cell.ladyLastContact.attributedText = item.lastInviteMessage;
        cell.ladyNameCenter.constant = -10;
    }else {
        cell.ladyLastContact.text = @"";
        cell.ladyLastContact.attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
        cell.ladyNameCenter.constant = 0;
    }
    
    [cell updateUI:item];
    
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"QNContactListTableView %ld self.items.count %ld",indexPath.row,self.items.count);
    if (indexPath.row < self.items.count) {
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectContact:)]) {
            [self.tableViewDelegate tableView:self didSelectContact:[self.items objectAtIndex:indexPath.row]];
        }
    }
}
@end
